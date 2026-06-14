#!/usr/bin/env bash
# adopt.sh - Guided adoption wizard for SpecOps Overlay.
#
# Run from the root of the repository that is adopting this overlay.
# The script copies the technology-agnostic overlay core, optionally applies a
# stack flavor, and fills AGENTS.md plus docs/project/* with project facts.
#
# Usage:
#   /path/to/specops-overlay/scripts/adopt.sh

set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET="$(pwd)"

# ---------------------------------------------------------------------------
# Colors and helpers
# ---------------------------------------------------------------------------

BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

info()    { printf "${CYAN}>${RESET} %s\n" "$*"; }
success() { printf "${GREEN}+${RESET} %s\n" "$*"; }
warn()    { printf "${YELLOW}!${RESET} %s\n" "$*"; }
error()   { printf "${RED}x${RESET} %s\n" "$*" >&2; }
heading() { printf "\n${BOLD}${CYAN}-- %s --${RESET}\n\n" "$*"; }

ask() {
    local var="$1" prompt="$2" default="${3:-}" input=""

    if [[ -n "$default" ]]; then
        printf "${BOLD}%s${RESET} ${DIM}[%s]${RESET}: " "$prompt" "$default"
    else
        printf "${BOLD}%s${RESET}: " "$prompt"
    fi

    read -r input || input=""
    printf -v "$var" "%s" "${input:-$default}"
}

confirm() {
    local prompt="${1:-Continue?}" answer=""
    printf "${BOLD}%s${RESET} ${DIM}[Y/n]${RESET}: " "$prompt"
    read -r answer || answer=""
    [[ -z "$answer" || "$answer" =~ ^[Yy] ]]
}

join_by() {
    local sep="$1"
    shift || true

    local item first=true
    for item in "$@"; do
        if [[ "$first" == true ]]; then
            printf "%s" "$item"
            first=false
        else
            printf "%s%s" "$sep" "$item"
        fi
    done
}

as_code() {
    if [[ -n "${1:-}" ]]; then
        printf '`%s`' "$1"
    fi
}

lowercase() {
    printf "%s" "$1" | tr '[:upper:]' '[:lower:]'
}

append_csv() {
    local current="$1" value="$2"

    if [[ -z "$value" ]]; then
        printf "%s" "$current"
    elif [[ -z "$current" ]]; then
        printf "%s" "$value"
    else
        printf "%s, %s" "$current" "$value"
    fi
}

# ---------------------------------------------------------------------------
# Flavor discovery
# ---------------------------------------------------------------------------

FLAVOR_IDS=()

discover_flavors() {
    local dir

    FLAVOR_IDS=()
    if [[ ! -d "$OVERLAY_ROOT/flavors" ]]; then
        return
    fi

    for dir in "$OVERLAY_ROOT"/flavors/*; do
        [[ -d "$dir" && -f "$dir/flavor.yaml" ]] || continue
        FLAVOR_IDS+=("$(basename "$dir")")
    done

    return 0
}

flavor_exists() {
    local id="$1" flavor
    for flavor in "${FLAVOR_IDS[@]}"; do
        [[ "$flavor" == "$id" ]] && return 0
    done
    return 1
}

flavor_label() {
    local id="$1" file label=""
    file="$OVERLAY_ROOT/flavors/$id/flavor.yaml"

    if [[ -f "$file" ]]; then
        label="$(awk -F': *' '$1 == "label" { print $2; exit }' "$file")"
    fi

    printf "%s" "${label:-$id}"
}

flavor_yaml_scalar() {
    local id="$1" parent="$2" key="$3" file
    file="$OVERLAY_ROOT/flavors/$id/flavor.yaml"

    [[ -f "$file" ]] || return

    awk -v parent="$parent" -v key="$key" '
        /^[^[:space:]][^:]*:/ {
            section = $0
            sub(/:.*/, "", section)
        }
        section == parent && $0 ~ "^[[:space:]]*" key ":[[:space:]]*" {
            sub("^[[:space:]]*" key ":[[:space:]]*", "")
            print
            exit
        }
    ' "$file"
}

flavor_yaml_list() {
    local id="$1" parent="$2" key="$3" file
    file="$OVERLAY_ROOT/flavors/$id/flavor.yaml"

    [[ -f "$file" ]] || return

    awk -v parent="$parent" -v key="$key" '
        /^[^[:space:]][^:]*:/ {
            section = $0
            sub(/:.*/, "", section)
            in_list = 0
        }
        section == parent && $0 ~ "^[[:space:]]*" key ":[[:space:]]*$" {
            in_list = 1
            next
        }
        in_list && /^[[:space:]]*-[[:space:]]*/ {
            value = $0
            sub(/^[[:space:]]*-[[:space:]]*/, "", value)
            values = values ? values ", " value : value
            next
        }
        in_list && /^[[:space:]]*[[:alnum:]_-]+:[[:space:]]*$/ {
            in_list = 0
        }
        in_list && !/^[[:space:]]/ {
            in_list = 0
        }
        END {
            print values
        }
    ' "$file"
}

flavor_command_value() {
    local id="$1" tool="$2" command="$3" file
    file="$OVERLAY_ROOT/flavors/$id/flavor.yaml"

    [[ -f "$file" ]] || return

    awk -v tool="$tool" -v command="$command" '
        /^commands:/ {
            in_commands = 1
            next
        }
        in_commands && /^[^[:space:]][^:]*:/ {
            exit
        }
        in_commands && $0 ~ "^  " tool ":[[:space:]]*$" {
            in_tool = 1
            next
        }
        in_commands && in_tool && /^  [^[:space:]-][^:]*:/ {
            in_tool = 0
        }
        in_tool && $0 ~ "^    " command ":[[:space:]]*" {
            sub("^    " command ":[[:space:]]*", "")
            print
            exit
        }
    ' "$file"
}

normalize_flavor_choice() {
    local choice="$1"

    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if (( choice == 1 )); then
            printf "generic"
            return 0
        fi

        local offset=$((choice - 2))
        if (( offset >= 0 && offset < ${#FLAVOR_IDS[@]} )); then
            printf "%s" "${FLAVOR_IDS[$offset]}"
            return 0
        fi
    fi

    if [[ "$choice" == "generic" ]]; then
        printf "generic"
        return 0
    fi

    if flavor_exists "$choice"; then
        printf "%s" "$choice"
        return 0
    fi

    return 1
}

choose_flavor() {
    local default_flavor="$1" raw_choice selected index id label

    heading "Flavor selection"

    info "Select the stack flavor to apply on top of the core overlay."
    printf "  1) generic - overlay core only; no stack-specific guidance\n"

    index=2
    for id in "${FLAVOR_IDS[@]}"; do
        label="$(flavor_label "$id")"
        printf "  %d) %s - %s\n" "$index" "$id" "$label"
        index=$((index + 1))
    done
    echo ""

    while true; do
        ask raw_choice "Flavor" "$default_flavor"
        if selected="$(normalize_flavor_choice "$raw_choice")"; then
            SELECTED_FLAVOR="$selected"
            break
        fi
        warn "Unknown flavor '$raw_choice'. Choose generic, a listed id, or a number."
    done

    if [[ "$SELECTED_FLAVOR" == "generic" ]]; then
        info "Selected generic adoption. No flavor files will be copied."
    else
        info "Selected flavor: $SELECTED_FLAVOR."
    fi
}

# ---------------------------------------------------------------------------
# Manifest and project detection
# ---------------------------------------------------------------------------

DETECTED_MANIFESTS=()
DEFAULT_LANGUAGE_RUNTIME=""
DEFAULT_FRAMEWORKS=""
DEFAULT_BUILD_TOOL=""
DEFAULT_PACKAGE_MANAGER=""
FLAVOR_SOURCE_ROOTS=""
FLAVOR_TEST_ROOTS=""
FLAVOR_RESOURCE_ROOTS=""

detect_manifest_file() {
    local file="$1"
    [[ -e "$TARGET/$file" ]] && DETECTED_MANIFESTS+=("$file")
    return 0
}

detect_manifests() {
    local file

    DETECTED_MANIFESTS=()

    for file in \
        pom.xml build.gradle build.gradle.kts settings.gradle settings.gradle.kts \
        package.json package-lock.json pnpm-lock.yaml yarn.lock bun.lockb \
        pyproject.toml setup.py setup.cfg requirements.txt Pipfile poetry.lock \
        Cargo.toml go.mod go.work Gemfile composer.json mix.exs rebar.config \
        Package.swift Dockerfile docker-compose.yml docker-compose.yaml \
        compose.yml compose.yaml Makefile justfile; do
        detect_manifest_file "$file"
    done

    for file in "$TARGET"/*.csproj "$TARGET"/*.fsproj "$TARGET"/*.sln; do
        [[ -e "$file" ]] && DETECTED_MANIFESTS+=("$(basename "$file")")
    done

    return 0
}

infer_defaults() {
    if [[ -f "$TARGET/package.json" ]]; then
        DEFAULT_LANGUAGE_RUNTIME="${DEFAULT_LANGUAGE_RUNTIME:-javascript/typescript}"
        if [[ -f "$TARGET/pnpm-lock.yaml" ]]; then
            DEFAULT_PACKAGE_MANAGER="${DEFAULT_PACKAGE_MANAGER:-pnpm}"
        elif [[ -f "$TARGET/yarn.lock" ]]; then
            DEFAULT_PACKAGE_MANAGER="${DEFAULT_PACKAGE_MANAGER:-yarn}"
        elif [[ -f "$TARGET/bun.lockb" ]]; then
            DEFAULT_PACKAGE_MANAGER="${DEFAULT_PACKAGE_MANAGER:-bun}"
        else
            DEFAULT_PACKAGE_MANAGER="${DEFAULT_PACKAGE_MANAGER:-npm}"
        fi
        DEFAULT_BUILD_TOOL="${DEFAULT_BUILD_TOOL:-$DEFAULT_PACKAGE_MANAGER}"
    fi

    if [[ -f "$TARGET/pyproject.toml" || -f "$TARGET/setup.py" || -f "$TARGET/requirements.txt" ]]; then
        DEFAULT_LANGUAGE_RUNTIME="${DEFAULT_LANGUAGE_RUNTIME:-Python}"
        if [[ -f "$TARGET/poetry.lock" ]]; then
            DEFAULT_PACKAGE_MANAGER="${DEFAULT_PACKAGE_MANAGER:-poetry}"
        elif [[ -f "$TARGET/Pipfile" ]]; then
            DEFAULT_PACKAGE_MANAGER="${DEFAULT_PACKAGE_MANAGER:-pipenv}"
        else
            DEFAULT_PACKAGE_MANAGER="${DEFAULT_PACKAGE_MANAGER:-pip}"
        fi
    fi

    if [[ -f "$TARGET/Cargo.toml" ]]; then
        DEFAULT_LANGUAGE_RUNTIME="${DEFAULT_LANGUAGE_RUNTIME:-Rust}"
        DEFAULT_BUILD_TOOL="${DEFAULT_BUILD_TOOL:-Cargo}"
        DEFAULT_PACKAGE_MANAGER="${DEFAULT_PACKAGE_MANAGER:-cargo}"
    fi

    if [[ -f "$TARGET/go.mod" ]]; then
        DEFAULT_LANGUAGE_RUNTIME="${DEFAULT_LANGUAGE_RUNTIME:-Go}"
        DEFAULT_BUILD_TOOL="${DEFAULT_BUILD_TOOL:-Go toolchain}"
    fi

    if [[ -f "$TARGET/Gemfile" ]]; then
        DEFAULT_LANGUAGE_RUNTIME="${DEFAULT_LANGUAGE_RUNTIME:-Ruby}"
        DEFAULT_PACKAGE_MANAGER="${DEFAULT_PACKAGE_MANAGER:-bundler}"
    fi

    if [[ -f "$TARGET/composer.json" ]]; then
        DEFAULT_LANGUAGE_RUNTIME="${DEFAULT_LANGUAGE_RUNTIME:-PHP}"
        DEFAULT_PACKAGE_MANAGER="${DEFAULT_PACKAGE_MANAGER:-composer}"
    fi

    if [[ -f "$TARGET/mix.exs" ]]; then
        DEFAULT_LANGUAGE_RUNTIME="${DEFAULT_LANGUAGE_RUNTIME:-Elixir}"
        DEFAULT_BUILD_TOOL="${DEFAULT_BUILD_TOOL:-Mix}"
    fi

    if [[ -f "$TARGET/Package.swift" ]]; then
        DEFAULT_LANGUAGE_RUNTIME="${DEFAULT_LANGUAGE_RUNTIME:-Swift}"
        DEFAULT_BUILD_TOOL="${DEFAULT_BUILD_TOOL:-Swift Package Manager}"
    fi

    return 0
}

apply_flavor_defaults() {
    local id="$1" language framework build_tool

    [[ "$id" != "generic" ]] || return 0

    language="$(flavor_yaml_scalar "$id" "defaults" "language")"
    framework="$(flavor_yaml_scalar "$id" "defaults" "framework")"
    build_tool="$(flavor_yaml_list "$id" "defaults" "build_tools")"
    build_tool="${build_tool%%,*}"

    DEFAULT_LANGUAGE_RUNTIME="${DEFAULT_LANGUAGE_RUNTIME:-$language}"
    DEFAULT_FRAMEWORKS="${DEFAULT_FRAMEWORKS:-$framework}"
    DEFAULT_BUILD_TOOL="${DEFAULT_BUILD_TOOL:-$build_tool}"
    FLAVOR_SOURCE_ROOTS="$(flavor_yaml_list "$id" "paths" "source_roots")"
    FLAVOR_TEST_ROOTS="$(flavor_yaml_list "$id" "paths" "test_roots")"
    FLAVOR_RESOURCE_ROOTS="$(flavor_yaml_list "$id" "paths" "resource_roots")"
}

tool_key() {
    local value
    value="$(lowercase "$1")"

    case "$value" in
        npm|pnpm|yarn|bun) printf "%s" "$value" ;;
        *cargo*) printf "cargo" ;;
        *go*) printf "go" ;;
        *mix*) printf "mix" ;;
        *make*) printf "make" ;;
        *) printf "%s" "$value" ;;
    esac
}

tool_command() {
    local key="$1"

    case "$key" in
        go)
            printf "go"
            ;;
        cargo)
            printf "cargo"
            ;;
        npm|pnpm|yarn|bun|mix|make)
            printf "%s" "$key"
            ;;
        *)
            printf "%s" "$key"
            ;;
    esac
}

infer_command_defaults() {
    local key="$1" cmd
    cmd="$(tool_command "$key")"

    DEFAULT_DEV_CMD=""
    DEFAULT_BUILD_CMD=""
    DEFAULT_TEST_CMD=""
    DEFAULT_IT_CMD=""
    DEFAULT_E2E_CMD=""
    DEFAULT_LINT_CMD=""
    DEFAULT_FORMAT_CMD=""

    if [[ "$SELECTED_FLAVOR" != "generic" ]]; then
        DEFAULT_DEV_CMD="$(flavor_command_value "$SELECTED_FLAVOR" "$key" "dev")"
        DEFAULT_BUILD_CMD="$(flavor_command_value "$SELECTED_FLAVOR" "$key" "build")"
        DEFAULT_TEST_CMD="$(flavor_command_value "$SELECTED_FLAVOR" "$key" "test")"
        DEFAULT_IT_CMD="$(flavor_command_value "$SELECTED_FLAVOR" "$key" "verify")"
    fi

    case "$key" in
        go)
            DEFAULT_BUILD_CMD="${DEFAULT_BUILD_CMD:-$cmd build ./...}"
            DEFAULT_TEST_CMD="${DEFAULT_TEST_CMD:-$cmd test ./...}"
            ;;
        cargo)
            DEFAULT_BUILD_CMD="${DEFAULT_BUILD_CMD:-$cmd build}"
            DEFAULT_TEST_CMD="${DEFAULT_TEST_CMD:-$cmd test}"
            DEFAULT_IT_CMD="${DEFAULT_IT_CMD:-$cmd test --all-targets}"
            ;;
        mix)
            DEFAULT_BUILD_CMD="${DEFAULT_BUILD_CMD:-$cmd compile}"
            DEFAULT_TEST_CMD="${DEFAULT_TEST_CMD:-$cmd test}"
            ;;
        make)
            DEFAULT_BUILD_CMD="${DEFAULT_BUILD_CMD:-$cmd build}"
            DEFAULT_TEST_CMD="${DEFAULT_TEST_CMD:-$cmd test}"
            ;;
    esac
}

infer_dirs() {
    local dir dirs=()

    for dir in "$@"; do
        [[ -d "$TARGET/$dir" ]] && dirs+=("$dir/")
    done

    join_by ", " "${dirs[@]}"
}

# ---------------------------------------------------------------------------
# File copy and template filling
# ---------------------------------------------------------------------------

copy_overlay_path() {
    local path="$1" required="${2:-true}"

    if [[ ! -e "$OVERLAY_ROOT/$path" ]]; then
        if [[ "$required" == true ]]; then
            error "Overlay path not found: $path"
            exit 1
        fi
        return
    fi

    rsync "${RSYNC_OPTS[@]}" "$OVERLAY_ROOT/$path" "$TARGET/"
}

copy_selected_flavor() {
    local flavor="$1"

    [[ "$flavor" != "generic" ]] || return

    if [[ ! -d "$OVERLAY_ROOT/flavors/$flavor" ]]; then
        error "Selected flavor not found: $OVERLAY_ROOT/flavors/$flavor"
        exit 1
    fi

    mkdir -p "$TARGET/flavors"
    rsync "${RSYNC_OPTS[@]}" "$OVERLAY_ROOT/flavors/$flavor" "$TARGET/flavors/"
}

apply_agents_flavor() {
    local agents_file="$1" patch_file="${2:-}" temp_file

    if ! grep -q '^<!-- FLAVOR:BEGIN -->$' "$agents_file" ||
       ! grep -q '^<!-- FLAVOR:END -->$' "$agents_file"; then
        warn "AGENTS.md has no flavor markers; flavor guidance was not injected."
        return
    fi

    temp_file="$(mktemp "$TARGET/.agents-flavor.XXXXXX")"

    awk -v patch="$patch_file" '
        $0 == "<!-- FLAVOR:BEGIN -->" {
            print
            if (patch != "") {
                while ((getline line < patch) > 0) {
                    print line
                }
                close(patch)
            }
            in_flavor = 1
            next
        }
        $0 == "<!-- FLAVOR:END -->" {
            in_flavor = 0
            print
            next
        }
        !in_flavor {
            print
        }
    ' "$agents_file" > "$temp_file"

    mv "$temp_file" "$agents_file"
}

replace_agents_defaults() {
    local agents_file="$1" block="$2" temp_file
    temp_file="$(mktemp "$TARGET/.agents-defaults.XXXXXX")"

    awk -v block="$block" '
        /^## Template Defaults \/ Fill After Adoption$/ {
            in_defaults = 1
            print
            next
        }
        in_defaults && /^## / {
            in_defaults = 0
        }
        in_defaults && /^- Language\/runtime:/ {
            replacing = 1
            print block
            next
        }
        in_defaults && replacing && /^$/ {
            replacing = 0
            in_defaults = 0
            print
            next
        }
        in_defaults && replacing {
            next
        }
        {
            print
        }
    ' "$agents_file" > "$temp_file"

    if grep -q "^- Language/runtime:" "$temp_file" &&
       grep -q "^- Build command:" "$temp_file"; then
        mv "$temp_file" "$agents_file"
    else
        rm -f "$temp_file"
        warn "Could not auto-fill AGENTS.md defaults; please edit that section manually."
    fi
}

fill_project_doc() {
    local file="$1" header="$2" content="$3" filepath
    filepath="$TARGET/docs/project/$file"

    if [[ ! -f "$filepath" ]]; then
        warn "docs/project/$file not found; skipping."
        return
    fi

    if grep -Eiq 'Template note:|Fill After Adoption|fill this file' "$filepath"; then
        printf "# %s\n\n%s\n" "$header" "$content" > "$filepath"
        success "docs/project/$file filled."
    else
        info "docs/project/$file already has content; leaving it unchanged."
    fi
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------

heading "SpecOps Overlay adoption wizard"

info "Overlay directory:   $OVERLAY_ROOT"
info "Target directory:    $TARGET"

if [[ "$OVERLAY_ROOT" == "$TARGET" ]]; then
    error "Cannot adopt SpecOps Overlay into itself."
    error "Run this script from the root of the adopting repository."
    exit 1
fi

if [[ ! -f "$OVERLAY_ROOT/AGENTS.md" ]]; then
    error "SpecOps Overlay not found at $OVERLAY_ROOT."
    error "Expected AGENTS.md in the overlay root."
    exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
    error "rsync is required to copy overlay files."
    exit 1
fi

detect_manifests
infer_defaults
discover_flavors

if [[ ! -d "$TARGET/.git" ]]; then
    warn "This directory is not a git repository."
    if ! confirm "Continue anyway?"; then
        exit 0
    fi
fi

BROWNFIELD=false
if (( ${#DETECTED_MANIFESTS[@]} > 0 )) ||
   [[ -d "$TARGET/src" || -d "$TARGET/app" || -d "$TARGET/lib" ]]; then
    BROWNFIELD=true
fi

if (( ${#DETECTED_MANIFESTS[@]} > 0 )); then
    info "Detected manifests: $(join_by ", " "${DETECTED_MANIFESTS[@]}")"
else
    info "No known build/runtime manifests detected."
fi

if [[ "$BROWNFIELD" == true ]]; then
    info "Existing project files detected; treating this as brownfield adoption."
else
    info "No project manifests or common source roots detected; treating this as greenfield adoption."
fi

DEFAULT_FLAVOR="generic"
choose_flavor "$DEFAULT_FLAVOR"
apply_flavor_defaults "$SELECTED_FLAVOR"

echo ""
if ! confirm "Ready to adopt SpecOps Overlay into $TARGET?"; then
    exit 0
fi

# ---------------------------------------------------------------------------
# Step 1: Copy overlay files
# ---------------------------------------------------------------------------

heading "Step 1 / 5 - Copy overlay files"

RSYNC_OPTS=(-a)
if [[ "$BROWNFIELD" == true ]]; then
    RSYNC_OPTS+=(--backup --suffix=.before-specops-overlay)
    info "Brownfield mode: existing overlay files will be backed up with .before-specops-overlay suffix."
fi

info "Copying overlay core files: AGENTS.md, docs/, skills/, openspec/, templates/."
copy_overlay_path "AGENTS.md"
copy_overlay_path "docs"
copy_overlay_path "skills"
copy_overlay_path "openspec"
copy_overlay_path "templates" false

if [[ "$SELECTED_FLAVOR" == "generic" ]]; then
    info "Skipping flavor copy for generic adoption."
else
    info "Copying flavor: flavors/$SELECTED_FLAVOR/."
    copy_selected_flavor "$SELECTED_FLAVOR"
fi

FLAVOR_PATCH=""
if [[ "$SELECTED_FLAVOR" != "generic" ]]; then
    FLAVOR_PATCH="$TARGET/flavors/$SELECTED_FLAVOR/AGENTS.patch.md"
    if [[ ! -f "$FLAVOR_PATCH" ]]; then
        warn "Flavor patch not found for $SELECTED_FLAVOR; AGENTS.md flavor block will stay empty."
        FLAVOR_PATCH=""
    fi
fi

apply_agents_flavor "$TARGET/AGENTS.md" "$FLAVOR_PATCH"
if [[ "$SELECTED_FLAVOR" == "generic" ]]; then
    success "AGENTS.md flavor block left empty for generic adoption."
else
    success "AGENTS.md flavor block filled for $SELECTED_FLAVOR."
fi

success "Overlay files copied."

# ---------------------------------------------------------------------------
# Step 2: Collect project facts
# ---------------------------------------------------------------------------

heading "Step 2 / 5 - Project facts"

info "Answer with stable project facts. Leave unknown fields blank."
echo ""

ask PROJECT_NAME "Project/service name" "$(basename "$TARGET")"

PRIMARY_NAMESPACE=""
PACKAGE_MANAGER=""

ask LANGUAGE_RUNTIME "Language/runtime" "$DEFAULT_LANGUAGE_RUNTIME"
ask FRAMEWORKS "Framework(s)" "$DEFAULT_FRAMEWORKS"
ask BUILD_TOOL "Build tool or task runner" "$DEFAULT_BUILD_TOOL"
ask PACKAGE_MANAGER "Package manager" "$DEFAULT_PACKAGE_MANAGER"
ask PRIMARY_NAMESPACE "Primary package/module/namespace" ""

ask ENTRYPOINT "Main service entry point" ""

BUILD_TOOL_KEY="$(tool_key "$BUILD_TOOL")"
infer_command_defaults "$BUILD_TOOL_KEY"

echo ""
info "Build and validation commands. Accept defaults only when they are real for this repository."

ask DEV_CMD "Local dev command" "$DEFAULT_DEV_CMD"
ask BUILD_CMD "Build command" "$DEFAULT_BUILD_CMD"
ask TEST_CMD "Unit test command" "$DEFAULT_TEST_CMD"
ask IT_CMD "Integration test command" "$DEFAULT_IT_CMD"
ask E2E_CMD "End-to-end test command" "$DEFAULT_E2E_CMD"
ask LINT_CMD "Static analysis/lint command" "$DEFAULT_LINT_CMD"
ask FORMAT_CMD "Formatting command" "$DEFAULT_FORMAT_CMD"

echo ""

DEFAULT_SOURCE_ROOTS="$(infer_dirs src app lib cmd internal pkg source sources)"
DEFAULT_TEST_ROOTS="$(infer_dirs test tests spec __tests__)"
DEFAULT_RESOURCE_ROOTS="$(infer_dirs resources config configs public static)"
DEFAULT_SOURCE_ROOTS="${DEFAULT_SOURCE_ROOTS:-$FLAVOR_SOURCE_ROOTS}"
DEFAULT_TEST_ROOTS="${DEFAULT_TEST_ROOTS:-$FLAVOR_TEST_ROOTS}"
DEFAULT_RESOURCE_ROOTS="${DEFAULT_RESOURCE_ROOTS:-$FLAVOR_RESOURCE_ROOTS}"

ask SOURCE_ROOTS "Source roots" "$DEFAULT_SOURCE_ROOTS"
ask TEST_ROOTS "Test roots" "$DEFAULT_TEST_ROOTS"
ask RESOURCE_ROOTS "Resource/config roots" "$DEFAULT_RESOURCE_ROOTS"

echo ""

ask DATABASE "Database (or none)" ""
ask MIGRATION_TOOL "Migration tool (or none)" ""
ask MESSAGING "Messaging/cache/search (or none)" ""
ask EXT_SERVICES "External services (or none)" ""
ask DEPLOY "Deployment platform (or unknown)" ""
ask TEST_FRAMEWORKS "Test frameworks" ""
ask STATIC_TOOLS "Static analysis/formatting tools" ""

DEFAULT_REQUIRED_ENV=""
DEFAULT_REQUIRED_ENV="$(append_csv "$DEFAULT_REQUIRED_ENV" "$LANGUAGE_RUNTIME")"
DEFAULT_REQUIRED_ENV="$(append_csv "$DEFAULT_REQUIRED_ENV" "$BUILD_TOOL")"
DEFAULT_REQUIRED_ENV="$(append_csv "$DEFAULT_REQUIRED_ENV" "$PACKAGE_MANAGER")"
ask REQUIRED_ENV "Required local environment/tooling" "$DEFAULT_REQUIRED_ENV"

# ---------------------------------------------------------------------------
# Step 3: Fill AGENTS.md template defaults
# ---------------------------------------------------------------------------

heading "Step 3 / 5 - Fill AGENTS.md"

AGENTS_FILE="$TARGET/AGENTS.md"

DEFAULTS_BLOCK="$(cat <<EOF
- Language/runtime: $LANGUAGE_RUNTIME
- Framework: $FRAMEWORKS
- Build tool: $BUILD_TOOL
- Main service entry point: $ENTRYPOINT
- Local dev command: $(as_code "$DEV_CMD")
- Build command: $(as_code "$BUILD_CMD")
- Unit test command: $(as_code "$TEST_CMD")
- Integration/e2e test command: $(as_code "${IT_CMD:-$E2E_CMD}")
- Static analysis/lint command: $(as_code "$LINT_CMD")
- Database: $DATABASE
- Messaging/cache/search: $MESSAGING
- External services: $EXT_SERVICES
- Required local environment: $REQUIRED_ENV
EOF
)"

replace_agents_defaults "$AGENTS_FILE" "$DEFAULTS_BLOCK"
success "AGENTS.md template defaults filled."

# ---------------------------------------------------------------------------
# Step 4: Fill docs/project/ files
# ---------------------------------------------------------------------------

heading "Step 4 / 5 - Fill docs/project/"

DETECTED_MANIFESTS_DISPLAY="$(join_by ", " "${DETECTED_MANIFESTS[@]}")"
DETECTED_MANIFESTS_DISPLAY="${DETECTED_MANIFESTS_DISPLAY:-none detected}"
SELECTED_FLAVOR_DISPLAY="$SELECTED_FLAVOR"

STACK_CONTENT="$(cat <<EOF
## Language and Runtime

- Language/runtime: $LANGUAGE_RUNTIME
- Frameworks: $FRAMEWORKS
- Selected workflow flavor: $SELECTED_FLAVOR_DISPLAY

## Build and Package Tooling

- Build tool or task runner: $BUILD_TOOL
- Package manager: $PACKAGE_MANAGER
- Detected manifests: $DETECTED_MANIFESTS_DISPLAY

## Data and Runtime Dependencies

- Database and migration tool: $DATABASE${MIGRATION_TOOL:+ / $MIGRATION_TOOL}
- Messaging/cache/search: $MESSAGING
- External services: $EXT_SERVICES

## Testing and Quality Tooling

- Test frameworks: $TEST_FRAMEWORKS
- Static analysis/formatting: $STATIC_TOOLS

## Deployment

- Platform: $DEPLOY

## Required Local Tooling

- Required local environment/tooling: $REQUIRED_ENV

## OpenSpec Use

Use this file to keep OpenSpec artifacts aligned with the real project stack.
Do not duplicate long setup instructions in \`openspec/config.yaml\`; reference
this file instead.
EOF
)"

fill_project_doc "STACK.md" "Stack" "$STACK_CONTENT"

TESTING_CONTENT="$(cat <<EOF
## Commands

- Build command: $(as_code "$BUILD_CMD")
- Unit test command: $(as_code "$TEST_CMD")
- Integration test command: $(as_code "$IT_CMD")
- End-to-end test command: $(as_code "$E2E_CMD")
- Static analysis command: $(as_code "$LINT_CMD")
- Formatting command: $(as_code "$FORMAT_CMD")
- Local dev command: $(as_code "$DEV_CMD")
- Migration validation command:
- Commands that require local services:
- CI-only checks:
- Local services required for integration/e2e tests:
- Test data reset or isolation command:
- Known checks that cannot run locally:

## Expected Test Levels

Fill these with the repository's conventions:

- Service/domain business rules:
- HTTP contracts:
- Persistence and transaction behavior:
- Messaging, jobs, and event consumers:
- Security and authorization:
- Configuration/startup behavior:
- External integrations and REST clients:
- Async or webhook outcomes:
- Migration validation and rollback/repair checks:

## OpenSpec Use

OpenSpec tasks for code changes should include the relevant checks from this
file. When acceptance criteria exist, tasks should map ACs to unit,
integration/e2e, and real-outcome proof. If a check cannot be run locally,
record the reason in the implementation summary or spec-driven evaluation.
EOF
)"

fill_project_doc "TESTING.md" "Testing" "$TESTING_CONTENT"

STRUCTURE_CONTENT="$(cat <<EOF
## Repository Layout

- Source roots: $SOURCE_ROOTS
- Test roots: $TEST_ROOTS
- Resource/config roots: $RESOURCE_ROOTS
- Primary package/module/namespace: $PRIMARY_NAMESPACE
- Main service entry point: $ENTRYPOINT
- Module layout:
- Generated files:
- Migration locations:
- Script locations:
- Ownership notes:
- Files or directories agents should avoid editing:

## OpenSpec Use

Use this file when planning changes that add files, modules, packages, or
tests. Keep the generated OpenSpec change artifacts under \`openspec/changes/\`.
EOF
)"

fill_project_doc "STRUCTURE.md" "Structure" "$STRUCTURE_CONTENT"

ARCH_CONTENT="$(cat <<EOF
## Purpose

- System boundaries and ownership.
- Module and bounded-context responsibilities.
- Deployment/runtime shape when it affects design choices.
- Architectural decisions that should guide future changes.

## Runtime Components

- Service/application: $PROJECT_NAME
- Main entry point: $ENTRYPOINT
- Database: $DATABASE
- Messaging/cache/search: $MESSAGING
- External services: $EXT_SERVICES

## Modules and Bounded Contexts

Fill after identifying domain boundaries.

## Data Ownership

Fill after identifying which module owns which persistent data.

## Communication Paths

- Synchronous:
- Asynchronous:

## Key Architectural Decisions

Fill as decisions are made.

## OpenSpec Use

Reference this file from \`openspec/config.yaml\` as engineering context for
proposals, designs, and implementation tasks. Put observable system behavior in
\`openspec/specs/\`, not here.
EOF
)"

fill_project_doc "ARCHITECTURE.md" "Architecture" "$ARCH_CONTENT"

CONVENTIONS_CONTENT="$(cat <<EOF
## Coding Conventions

- Primary package/module/namespace: $PRIMARY_NAMESPACE
- Module and file naming:
- Function, method, or class naming:
- API naming:
- Data transfer and validation conventions:
- Error handling conventions:
- Transaction or persistence conventions:
- Logging conventions:
- Commit or branch conventions:

## OpenSpec Use

Use these conventions when writing OpenSpec designs and tasks. If a proposed
change needs to break a convention, document the reason in the design.
EOF
)"

fill_project_doc "CONVENTIONS.md" "Conventions" "$CONVENTIONS_CONTENT"

INTEGRATIONS_CONTENT="$(cat <<EOF
## External Systems

- External APIs: $EXT_SERVICES
- Auth providers:
- Databases: $DATABASE
- Migration tool: $MIGRATION_TOOL
- Messaging systems: $MESSAGING
- Caches:
- Search/indexing systems:
- Observability tools:
- Local dependency startup:
- Contract or sandbox documentation:

## OpenSpec Use

Use this file when a change touches external systems. Keep vendor contracts and
integration constraints here, and keep observable project behavior in
\`openspec/specs/\`.
EOF
)"

fill_project_doc "INTEGRATIONS.md" "Integrations" "$INTEGRATIONS_CONTENT"

CONCERNS_CONTENT="$(cat <<EOF
## Risks and Constraints

- Security concerns:
- Privacy or compliance concerns:
- Performance limits:
- Reliability risks:
- Migration or rollout risks:
- Known technical debt:
- Local development constraints:
- Production constraints:

## OpenSpec Use

When creating OpenSpec proposals and designs, call out relevant concerns and
explain how the change handles them.
EOF
)"

fill_project_doc "CONCERNS.md" "Concerns" "$CONCERNS_CONTENT"

# ---------------------------------------------------------------------------
# Step 5: Next steps
# ---------------------------------------------------------------------------

heading "Step 5 / 5 - Next steps"

success "SpecOps Overlay adopted successfully."
echo ""

info "Files created or updated:"
echo "  - AGENTS.md"
echo "  - docs/project/*.md"
echo "  - skills/"
echo "  - openspec/"
if [[ "$SELECTED_FLAVOR" != "generic" ]]; then
    echo "  - flavors/$SELECTED_FLAVOR/"
fi
if [[ -d "$TARGET/templates" ]]; then
    echo "  - templates/"
fi
echo ""

if [[ "$BROWNFIELD" == true ]]; then
    warn "Brownfield adoption: backed-up files have .before-specops-overlay suffix."
    info "Review diffs and merge any existing project-specific rules."
    info "Use skills/brownfield-mapping/SKILL.md to replace guesses with observed facts."
    echo ""
fi

echo -e "${BOLD}Recommended next actions:${RESET}"
echo ""
echo "  1. Review and refine AGENTS.md and docs/project/*.md."
echo "  2. Confirm openspec/config.yaml matches the desired workflow profile."

if [[ "$SELECTED_FLAVOR" != "generic" ]]; then
    echo "  3. Review flavors/$SELECTED_FLAVOR/ guidance and keep only applicable stack rules."
    NEXT_STEP=4
else
    NEXT_STEP=3
fi

echo "  $NEXT_STEP. Install OpenSpec and initialize tool integrations when ready:"
echo ""
echo "     npm install -g @fission-ai/openspec@latest"
echo "     openspec init"
echo ""
echo "  $((NEXT_STEP + 1)). Commit the adopted overlay:"
echo ""
if [[ "$SELECTED_FLAVOR" == "generic" ]]; then
    echo "     git add AGENTS.md docs/ skills/ openspec/ templates/"
else
    echo "     git add AGENTS.md docs/ skills/ openspec/ templates/ flavors/$SELECTED_FLAVOR/"
fi
echo "     git commit -m 'adopt specops overlay'"
echo ""

success "Done."
