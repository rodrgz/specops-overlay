#!/usr/bin/env bash
# adopt.sh - Copy SpecOps Overlay into an adopting repository.
#
# Run from the root of the repository that is adopting this overlay.
#
# Usage:
#   /path/to/specops-overlay/scripts/adopt.sh [--flavor <id>] [--schema evidence-first] [--force]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET="$(pwd)"

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

info() { printf "${CYAN}>${RESET} %s\n" "$*"; }
success() { printf "${GREEN}+${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}!${RESET} %s\n" "$*"; }
error() { printf "${RED}x${RESET} %s\n" "$*" >&2; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [--flavor <id>] [--schema <name>] [--force]

Options:
  --flavor <id>  Inject stack flavor guidance from flavors/<id>.
  --schema <name> Install an optional OpenSpec schema. Supported: evidence-first.
  --force        Back up existing destination paths before overwriting them.
  -h, --help     Show this help.
EOF
}

SELECTED_FLAVOR=""
SELECTED_SCHEMA=""
FORCE=false
COPY_SOURCES=()
COPY_DESTS=()
ENSURE_DIRS=()

while (($# > 0)); do
    case "$1" in
        --flavor)
            [[ $# -ge 2 ]] || {
                error "--flavor requires a value"
                exit 2
            }
            SELECTED_FLAVOR="$2"
            shift 2
            ;;
        --flavor=*)
            SELECTED_FLAVOR="${1#--flavor=}"
            shift
            ;;
        --schema)
            [[ $# -ge 2 ]] || {
                error "--schema requires a value"
                exit 2
            }
            SELECTED_SCHEMA="$2"
            shift 2
            ;;
        --schema=*)
            SELECTED_SCHEMA="${1#--schema=}"
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown argument: $1"
            usage >&2
            exit 2
            ;;
    esac
done

require_source() {
    local path="$1"
    [[ -e "$OVERLAY_ROOT/$path" ]] || {
        error "Overlay source path missing: $path"
        exit 1
    }
}

is_brownfield() {
    local path

    for path in \
        .git src app lib package.json pom.xml pyproject.toml Cargo.toml go.mod; do
        [[ -e "$TARGET/$path" ]] && return 0
    done

    return 1
}

backup_path() {
    local path="$1" backup counter

    backup="$path.before-specops-overlay"
    counter=1
    while [[ -e "$backup" ]]; do
        backup="$path.before-specops-overlay.$counter"
        counter=$((counter + 1))
    done

    mv "$path" "$backup"
    info "Backed up ${path#$TARGET/} -> ${backup#$TARGET/}"
}

register_copy() {
    local src_rel="$1" dest_rel="$2"

    require_source "$src_rel"
    COPY_SOURCES+=("$src_rel")
    COPY_DESTS+=("$dest_rel")
}

register_dir() {
    ENSURE_DIRS+=("$1")
}

check_collisions() {
    local dest_rel dest
    local collisions=()

    [[ "$FORCE" != true ]] || return 0

    for dest_rel in "${COPY_DESTS[@]}"; do
        dest="$TARGET/$dest_rel"
        [[ -e "$dest" ]] && collisions+=("$dest_rel")
    done

    if ((${#collisions[@]} > 0)); then
        error "Destination paths already exist:"
        printf '  - %s\n' "${collisions[@]}" >&2
        error "Re-run with --force to back them up with .before-specops-overlay suffixes."
        exit 1
    fi
}

copy_path() {
    local src_rel="$1" dest_rel="$2" src dest parent

    src="$OVERLAY_ROOT/$src_rel"
    dest="$TARGET/$dest_rel"
    parent="$(dirname "$dest")"

    if [[ -e "$dest" ]]; then
        backup_path "$dest"
    fi

    mkdir -p "$parent"
    cp -a "$src" "$dest"
}

copy_registered_paths() {
    local i

    for i in "${!COPY_SOURCES[@]}"; do
        copy_path "${COPY_SOURCES[$i]}" "${COPY_DESTS[$i]}"
    done
}

ensure_registered_dirs() {
    local dir_rel dir

    for dir_rel in "${ENSURE_DIRS[@]}"; do
        dir="$TARGET/$dir_rel"
        mkdir -p "$dir"
        [[ -e "$dir/.gitkeep" ]] || printf '\n' > "$dir/.gitkeep"
    done
}

apply_agents_flavor() {
    local agents_file="$1" patch_file="$2" temp_file

    [[ -n "$patch_file" ]] || return 0

    if ! grep -q '^<!-- FLAVOR:BEGIN -->$' "$agents_file" ||
       ! grep -q '^<!-- FLAVOR:END -->$' "$agents_file"; then
        warn "AGENTS.md has no flavor markers; flavor guidance was not injected."
        return 0
    fi

    temp_file="$(mktemp "$TARGET/.agents-flavor.XXXXXX")"

    awk -v patch="$patch_file" '
        $0 == "<!-- FLAVOR:BEGIN -->" {
            print
            while ((getline line < patch) > 0) {
                print line
            }
            close(patch)
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

apply_openspec_schema() {
    local config_file="$1" schema_name="$2" temp_file

    [[ -n "$schema_name" ]] || return 0

    temp_file="$(mktemp "$TARGET/.openspec-config.XXXXXX")"

    awk -v schema="$schema_name" '
        BEGIN { replaced = 0 }
        /^schema:/ && replaced == 0 {
            print "schema: " schema
            replaced = 1
            next
        }
        { print }
        END {
            if (replaced == 0) {
                print "schema: " schema
            }
        }
    ' "$config_file" > "$temp_file"

    mv "$temp_file" "$config_file"
}

OVERLAY_REAL="$(cd "$OVERLAY_ROOT" && pwd -P)"
TARGET_REAL="$(cd "$TARGET" && pwd -P)"

info "Overlay directory: $OVERLAY_ROOT"
info "Target directory:  $TARGET"

if [[ "$OVERLAY_REAL" == "$TARGET_REAL" ]]; then
    error "Cannot adopt SpecOps Overlay into itself."
    error "Run this script from the root of the adopting repository."
    exit 1
fi

require_source "AGENTS.md"
require_source "docs/project"
require_source "skills"
require_source "openspec/config.yaml"
require_source "templates"
require_source "flavors"

if [[ -n "$SELECTED_SCHEMA" && "$SELECTED_SCHEMA" != "evidence-first" ]]; then
    error "Unsupported schema: $SELECTED_SCHEMA"
    error "Supported schema: evidence-first"
    exit 2
fi

if [[ "$SELECTED_SCHEMA" == "evidence-first" ]]; then
    require_source "openspec/schemas/evidence-first"
fi

if [[ -n "$SELECTED_FLAVOR" ]]; then
    require_source "flavors/$SELECTED_FLAVOR/flavor.yaml"
    require_source "flavors/$SELECTED_FLAVOR/AGENTS.patch.md"
fi

if is_brownfield; then
    BROWNFIELD=true
    warn "Brownfield project detected."
else
    BROWNFIELD=false
    info "No common project markers detected; treating target as greenfield."
fi

register_copy "AGENTS.md" "AGENTS.md"
register_copy "docs/project" "docs/project"
register_copy "skills" ".agents/skills"
register_copy "openspec/config.yaml" "openspec/config.yaml"
register_copy "templates" "openspec/specops/templates"
register_copy "flavors" "openspec/specops/flavors"
if [[ "$SELECTED_SCHEMA" == "evidence-first" ]]; then
    register_copy "openspec/schemas/evidence-first" "openspec/schemas/evidence-first"
fi
register_dir "openspec/specs"
register_dir "openspec/changes"
register_dir "openspec/changes/archive"

check_collisions
copy_registered_paths
ensure_registered_dirs

if [[ -n "$SELECTED_FLAVOR" ]]; then
    FLAVOR_PATCH="$TARGET/openspec/specops/flavors/$SELECTED_FLAVOR/AGENTS.patch.md"
    apply_agents_flavor "$TARGET/AGENTS.md" "$FLAVOR_PATCH"
    success "Injected flavor guidance: $SELECTED_FLAVOR."
else
    success "Generic adoption selected; no flavor guidance injected."
fi

if [[ "$SELECTED_SCHEMA" == "evidence-first" ]]; then
    apply_openspec_schema "$TARGET/openspec/config.yaml" "$SELECTED_SCHEMA"
    success "Installed OpenSpec schema: $SELECTED_SCHEMA."
else
    success "Lightweight OpenSpec schema selected; no optional schema installed."
fi

success "SpecOps Overlay adopted successfully."
echo ""
info "Files created or updated:"
echo "  - AGENTS.md"
echo "  - docs/project/"
echo "  - openspec/"
echo "  - openspec/specops/templates/"
echo "  - openspec/specops/flavors/"
echo "  - .agents/skills/"
echo ""

if [[ "$BROWNFIELD" == true ]]; then
    warn "Next: use .agents/skills/brownfield-mapping/SKILL.md to fill docs/project/* from observed files before implementation work."
else
    info "Next: fill AGENTS.md and docs/project/* with real project facts."
fi

echo ""
echo "Recommended next commands:"
echo "  git add AGENTS.md docs/ openspec/ .agents/"
echo "  git commit -m 'adopt specops overlay'"
echo ""
echo "OpenSpec tooling can be generated later with: openspec init"
