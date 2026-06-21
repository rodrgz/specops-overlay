#!/usr/bin/env bash
# validate.sh - Local validation for the SpecOps Overlay kit.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info() { printf '> %s\n' "$*"; }
pass() { printf '+ %s\n' "$*"; }
fail() { printf 'x %s\n' "$*" >&2; exit 1; }
warn() { printf '! %s\n' "$*" >&2; }

require_path() {
    local path="$1"
    [[ -e "$ROOT/$path" ]] || fail "Missing required path: $path"
}

check_internal_references() {
    info "Checking required internal references"

    local paths=(
        AGENTS.md
        README.md
        LICENSE
        CONTRIBUTING.md
        CHANGELOG.md
        openspec/config.yaml
        templates/proposal.md
        templates/spec.md
        templates/design.md
        templates/tasks.md
        templates/ac-proof-matrix.md
        templates/evaluation.md
        skills/spec-quality-gate/SKILL.md
        skills/spec-quality-gate/references/implicit-requirements.md
        skills/spec-quality-gate/references/ac-proof-matrix.md
        skills/spec-quality-gate/references/test-strategy.md
        skills/spec-quality-gate/references/scope-discipline.md
        skills/spec-driven-eval/SKILL.md
        skills/spec-driven-eval/references/reference.md
        scripts/adopt.sh
    )

    local path
    for path in "${paths[@]}"; do
        require_path "$path"
    done

    pass "Internal references exist"
}

check_shell() {
    info "Checking shell scripts"

    bash -n "$ROOT/scripts/adopt.sh"
    bash -n "$ROOT/scripts/validate.sh"

    if command -v shellcheck >/dev/null 2>&1; then
        shellcheck "$ROOT/scripts/adopt.sh" "$ROOT/scripts/validate.sh"
        pass "shellcheck passed"
    else
        warn "shellcheck not installed; bash -n fallback passed"
    fi
}

run_adoption_case() {
    local flavor="$1"
    local tmp target log

    info "Running adoption dry run in /tmp ($flavor)"

    tmp="$(mktemp -d /tmp/specops-overlay-validate.XXXXXX)"
    target="$tmp/target"
    log="$tmp/adopt.log"

    mkdir -p "$target"
    git -C "$target" init -q

    {
        printf '%s\n' "$flavor"
        printf 'Y\n'   # ready to adopt
        local i
        for i in $(seq 1 40); do
            printf '\n'
        done
    } | (cd "$target" && "$ROOT/scripts/adopt.sh" >"$log")

    local expected=(
        AGENTS.md
        docs/project/ARCHITECTURE.md
        docs/project/STACK.md
        skills/spec-quality-gate/SKILL.md
        openspec/config.yaml
        templates/tasks.md
    )

    if [[ "$flavor" != "generic" ]]; then
        expected+=("flavors/$flavor/flavor.yaml")
        expected+=("flavors/$flavor/AGENTS.patch.md")
    fi

    local path
    for path in "${expected[@]}"; do
        [[ -e "$target/$path" ]] || {
            sed -n '1,160p' "$log" >&2
            rm -rf "$tmp"
            fail "Adoption dry run did not create $path"
        }
    done

    rm -rf "$tmp"
    pass "Adoption dry run created expected files ($flavor)"
}

check_adoption_dry_run() {
    run_adoption_case "generic"
    run_adoption_case "java-quarkus"
}

check_template_traceability() {
    info "Checking template traceability and task discipline"

    if grep -q '^## Tests And Proof$' "$ROOT/templates/tasks.md"; then
        fail "templates/tasks.md contains deferred Tests And Proof block"
    fi

    grep -q 'Tests:' "$ROOT/templates/tasks.md" ||
        fail "templates/tasks.md does not include Tests fields"
    grep -q 'Gate:' "$ROOT/templates/tasks.md" ||
        fail "templates/tasks.md does not include Gate fields"
    grep -q 'Done when:' "$ROOT/templates/tasks.md" ||
        fail "templates/tasks.md does not include Done when fields"
    grep -q 'Maps to:' "$ROOT/templates/tasks.md" ||
        fail "templates/tasks.md does not include Maps to fields"
    grep -q 'RED/GREEN' "$ROOT/templates/tasks.md" ||
        fail "templates/tasks.md does not include RED/GREEN guidance"
    grep -q 'New Capabilities' "$ROOT/templates/proposal.md" ||
        fail "templates/proposal.md does not include capability sections"

    rg -q 'REQ-[0-9]{3}-AC-[0-9]{3}' \
        "$ROOT/templates" "$ROOT/skills" "$ROOT/openspec" ||
        fail "No stable AC ID examples found"

    pass "Template traceability checks passed"
}

check_secret_scan() {
    info "Scanning tracked files for obvious secrets"

    local pattern
    pattern='(sk-[A-Za-z0-9][A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN (RSA|OPENSSH|EC|DSA)? ?PRIVATE KEY-----)'

    local existing_files=()
    local path
    while IFS= read -r -d '' path; do
        [[ -e "$ROOT/$path" ]] && existing_files+=("$ROOT/$path")
    done < <(git -C "$ROOT" ls-files -z)

    if ((${#existing_files[@]} > 0)) &&
        rg -n --pcre2 "$pattern" "${existing_files[@]}"; then
        fail "Potential secret found in tracked files"
    fi

    pass "No obvious tracked secrets found"
}

check_openspec() {
    info "Checking OpenSpec change structure"

    if command -v openspec >/dev/null 2>&1; then
        local changes=()
        local proposal
        local change

        while IFS= read -r -d '' proposal; do
            change="$(basename "$(dirname "$proposal")")"
            changes+=("$change")
        done < <(find "$ROOT/openspec/changes" -mindepth 2 -maxdepth 2 -name proposal.md -print0 | sort -z)

        if ((${#changes[@]} == 0)); then
            warn "No active OpenSpec changes with proposal.md; skipping structural validation"
            return
        fi

        for change in "${changes[@]}"; do
            (cd "$ROOT" && openspec validate "$change")
        done

        pass "OpenSpec validation passed (${#changes[@]} change(s))"
    else
        warn "openspec not installed; skipping structural validation"
    fi
}

main() {
    check_internal_references
    check_shell
    check_adoption_dry_run
    check_template_traceability
    check_secret_scan
    check_openspec
    pass "All available overlay validation checks passed"
}

main "$@"
