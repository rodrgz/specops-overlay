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
        openspec/specs
        openspec/changes
        templates/proposal.md
        templates/spec.md
        templates/design.md
        templates/tasks.md
        templates/ac-proof-matrix.md
        templates/evaluation.md
        openspec/schemas/evidence-first/schema.yaml
        openspec/schemas/evidence-first/templates/proposal.md
        openspec/schemas/evidence-first/templates/spec.md
        openspec/schemas/evidence-first/templates/design.md
        openspec/schemas/evidence-first/templates/proof.md
        openspec/schemas/evidence-first/templates/tasks.md
        openspec/schemas/evidence-first/templates/evaluation.md
        flavors/java-quarkus/flavor.yaml
        flavors/node-typescript/flavor.yaml
        skills/brownfield-mapping/SKILL.md
        skills/spec-quality-gate/SKILL.md
        skills/spec-quality-gate/references/implicit-requirements.md
        skills/spec-quality-gate/references/ac-proof-matrix.md
        skills/spec-quality-gate/references/test-strategy.md
        skills/spec-quality-gate/references/scope-discipline.md
        skills/spec-driven-eval/SKILL.md
        skills/spec-driven-eval/references/reference.md
        skills/pr-review/SKILL.md
        scripts/adopt.sh
        scripts/validate.sh
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
    local schema="${2:-}"
    local tmp target log
    local args=()
    local label="$flavor"

    if [[ -n "$schema" ]]; then
        label="$label, schema=$schema"
    fi

    info "Running adoption dry run in /tmp ($label)"

    tmp="$(mktemp -d /tmp/specops-overlay-validate.XXXXXX)"
    target="$tmp/target"
    log="$tmp/adopt.log"

    mkdir -p "$target"
    git -C "$target" init -q

    if [[ "$flavor" != "generic" ]]; then
        args=(--flavor "$flavor")
    fi
    if [[ -n "$schema" ]]; then
        args+=(--schema "$schema")
    fi

    if ! (cd "$target" && "$ROOT/scripts/adopt.sh" "${args[@]}" >"$log" 2>&1); then
        sed -n '1,180p' "$log" >&2
        rm -rf "$tmp"
        fail "Adoption dry run failed ($label)"
    fi

    local expected=(
        AGENTS.md
        docs/project/ARCHITECTURE.md
        docs/project/STACK.md
        .agents/skills/brownfield-mapping/SKILL.md
        .agents/skills/spec-quality-gate/SKILL.md
        .agents/skills/spec-driven-eval/SKILL.md
        openspec/config.yaml
        openspec/specs/.gitkeep
        openspec/changes/.gitkeep
        openspec/changes/archive/.gitkeep
        openspec/specops/templates/tasks.md
        openspec/specops/flavors/java-quarkus/flavor.yaml
        openspec/specops/flavors/node-typescript/flavor.yaml
    )

    if [[ "$flavor" != "generic" ]]; then
        expected+=("openspec/specops/flavors/$flavor/AGENTS.patch.md")
        grep -q "Stack Flavor:" "$target/AGENTS.md" || {
            sed -n '1,180p' "$log" >&2
            rm -rf "$tmp"
            fail "Adoption dry run did not inject flavor guidance ($label)"
        }
    fi

    if [[ "$schema" == "evidence-first" ]]; then
        expected+=(
            openspec/schemas/evidence-first/schema.yaml
            openspec/schemas/evidence-first/templates/proof.md
            openspec/schemas/evidence-first/templates/evaluation.md
        )
        grep -q '^schema: evidence-first$' "$target/openspec/config.yaml" || {
            sed -n '1,180p' "$log" >&2
            rm -rf "$tmp"
            fail "Adoption dry run did not configure evidence-first schema"
        }
    else
        [[ ! -e "$target/openspec/schemas/evidence-first" ]] || {
            sed -n '1,180p' "$log" >&2
            rm -rf "$tmp"
            fail "Generic adoption installed optional evidence-first schema"
        }
        grep -q '^schema: spec-driven$' "$target/openspec/config.yaml" || {
            sed -n '1,180p' "$log" >&2
            rm -rf "$tmp"
            fail "Generic adoption did not keep spec-driven schema"
        }
    fi

    local path
    for path in "${expected[@]}"; do
        [[ -e "$target/$path" ]] || {
            sed -n '1,180p' "$log" >&2
            rm -rf "$tmp"
            fail "Adoption dry run did not create $path"
        }
    done

    rm -rf "$tmp"
    pass "Adoption dry run created expected files ($label)"
}

check_adoption_dry_run() {
    run_adoption_case "generic"
    run_adoption_case "java-quarkus"
    run_adoption_case "node-typescript"
    run_adoption_case "generic" "evidence-first"
}

check_evidence_first_schema() {
    info "Checking evidence-first OpenSpec schema"

    if command -v openspec >/dev/null 2>&1; then
        (cd "$ROOT" && openspec schemas --json | rg -q '"name": "evidence-first"') ||
            fail "OpenSpec did not discover evidence-first schema"
        (cd "$ROOT" && openspec schemas --json | rg -q '"source": "project"') ||
            fail "OpenSpec did not report project-local schema source"
        (cd "$ROOT" && openspec schema validate evidence-first)
        (cd "$ROOT" && openspec templates --schema evidence-first --json | rg -q '"proof"') ||
            fail "OpenSpec did not resolve evidence-first proof template"
        (cd "$ROOT" && openspec templates --schema evidence-first --json | rg -q '"evaluation"') ||
            fail "OpenSpec did not resolve evidence-first evaluation template"
        pass "Evidence-first schema validation passed"
    else
        warn "openspec not installed; evidence-first schema validation unavailable"
    fi
}

check_template_traceability() {
    info "Checking template traceability and task discipline"

    local templates="$ROOT/templates"

    if grep -q '^## Tests And Proof$' "$templates/tasks.md"; then
        fail "templates/tasks.md contains deferred Tests And Proof block"
    fi

    grep -q 'Tests:' "$templates/tasks.md" ||
        fail "tasks template does not include Tests fields"
    grep -q 'Gate:' "$templates/tasks.md" ||
        fail "tasks template does not include Gate fields"
    grep -q 'Done when:' "$templates/tasks.md" ||
        fail "tasks template does not include Done when fields"
    grep -q 'Maps to:' "$templates/tasks.md" ||
        fail "tasks template does not include Maps to fields"
    grep -q 'RED/GREEN' "$templates/tasks.md" ||
        fail "tasks template does not include RED/GREEN guidance"
    grep -q 'New Capabilities' "$templates/proposal.md" ||
        fail "proposal template does not include capability sections"

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

check_template_governance() {
    info "Checking template source governance"

    # REQ-003-AC-001: Required evidence-first schema templates must exist.
    local required_schema_templates=(
        openspec/schemas/evidence-first/templates/proposal.md
        openspec/schemas/evidence-first/templates/spec.md
        openspec/schemas/evidence-first/templates/design.md
        openspec/schemas/evidence-first/templates/proof.md
        openspec/schemas/evidence-first/templates/tasks.md
        openspec/schemas/evidence-first/templates/evaluation.md
    )

    local tmpl
    for tmpl in "${required_schema_templates[@]}"; do
        [[ -e "$ROOT/$tmpl" ]] ||
            fail "Missing required evidence-first schema template: $tmpl"
    done
    pass "Required evidence-first schema templates exist"

    # REQ-003-AC-002: README and CONTRIBUTING must contain canonical ownership guidance.
    grep -q 'Where to Edit' "$ROOT/README.md" ||
        fail "README.md missing canonical template ownership guidance (expected 'Where to Edit' section)"
    grep -q 'Strict schema-owned' "$ROOT/README.md" ||
        fail "README.md missing schema-owned template classification"
    grep -q 'Lightweight reusable' "$ROOT/README.md" ||
        fail "README.md missing lightweight reusable template classification"

    grep -q 'Edit Routing' "$ROOT/CONTRIBUTING.md" ||
        fail "CONTRIBUTING.md missing edit-routing guidance (expected 'Edit Routing' section)"
    grep -q 'openspec/schemas/evidence-first/templates/' "$ROOT/CONTRIBUTING.md" ||
        fail "CONTRIBUTING.md missing schema template path in edit-routing guidance"

    pass "Canonical template ownership guidance present in docs"
}

check_path_convention() {
    info "Checking adopter-relative path convention in docs and config"

    # Documentation and config files use adopter-relative paths so they
    # resolve correctly after adopt.sh copies them. These patterns catch
    # source-relative backtick-quoted paths that should have been transformed.
    #
    # Exclude: scripts/ (reference source paths legitimately),
    #          CONTRIBUTING.md (documents source layout),
    #          README.md Repository Contents section (describes source layout),
    #          this file, and non-text files.

    local scan_files=(
        "$ROOT/AGENTS.md"
        "$ROOT/openspec/config.yaml"
        "$ROOT/docs/adoption-prompts.md"
        "$ROOT/docs/project"
    )

    local scan_dirs=(
        "$ROOT/skills"
        "$ROOT/templates"
        "$ROOT/flavors"
    )

    local targets=()
    local f
    for f in "${scan_files[@]}"; do
        [[ -e "$f" ]] && targets+=("$f")
    done
    for f in "${scan_dirs[@]}"; do
        [[ -d "$f" ]] && targets+=("$f")
    done

    if ((${#targets[@]} == 0)); then
        warn "No files to scan for path convention"
        return
    fi

    # Match backtick-quoted source-relative paths that should be adopter-relative.
    # Example bad: `skills/foo/SKILL.md`  (should be `.agents/skills/foo/SKILL.md`)
    # Example bad: `templates/tasks.md`   (should be `openspec/specops/templates/tasks.md`)
    # Example bad: `flavors/java-quarkus/docs/FOO.md` (should be `openspec/specops/flavors/...`)
    #
    # The pattern requires a slash after the keyword to avoid matching prose
    # like "skills," or "templates." and only triggers inside backticks.
    # Paths with angle-bracket placeholders like `flavors/<id>/` are generic
    # prose references, not resolvable cross-references, and are excluded.
    local pattern='`(skills/[^`<]+|templates/[^`<]+|flavors/[^`<]+)`'

    if rg --pcre2 -n "$pattern" "${targets[@]}" 2>/dev/null; then
        fail "Source-relative paths found in docs/config (should use adopter-relative paths; see README.md#applied-project-map)"
    fi

    pass "Adopter-relative path convention respected"
}

main() {
    check_internal_references
    check_shell
    check_adoption_dry_run
    check_evidence_first_schema
    check_template_traceability
    check_template_governance
    check_path_convention
    check_secret_scan
    check_openspec
    pass "All available overlay validation checks passed"
}

main "$@"
