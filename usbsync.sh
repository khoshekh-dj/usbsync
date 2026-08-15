#!/bin/zsh

SCRIPT_NAME="$(basename "$0")"

# --- CONFIGURATION DEFAULTS ---
DEFAULT_SOURCE="/Volumes/PRI"
DEFAULT_BACKUP="/Volumes/SEC"

SOURCE=""
BACKUP=""

# --- HELP MESSAGE ---
show_help() {
    echo "Usage: $SCRIPT_NAME [OPTIONS] [SOURCE] [DESTINATION]"
    echo ""
    echo "Sync files from SOURCE to DESTINATION using rsync."
    echo ""
    echo "Arguments:"
    echo "  SOURCE                  Path to source directory"
    echo "  DESTINATION             Path to destination directory"
    echo ""
    echo "Options:"
    echo "  -s, --source PATH       Specify source directory"
    echo "  -d, --dest, --destination PATH"
    echo "                          Specify destination directory"
    echo "  -h, --help              Display this help message and exit"
    echo ""
    echo "If SOURCE or DESTINATION are omitted, you will be prompted"
    echo "to enter them or press Enter to accept the defaults:"
    echo "  Default Source:      $DEFAULT_SOURCE"
    echo "  Default Destination: $DEFAULT_BACKUP"
    exit 0
}

# --- PARSE CLI ARGUMENTS ---
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -s|--source)
            SOURCE="$2"
            shift 2
            ;;
        -d|--dest|--destination)
            BACKUP="$2"
            shift 2
            ;;
        *)
            if [ -z "$SOURCE" ]; then
                SOURCE="$1"
            elif [ -z "$BACKUP" ]; then
                BACKUP="$1"
            else
                echo "❌ ERROR: Unexpected argument: $1"
                echo "Run '$SCRIPT_NAME --help' for usage."
                exit 1
            fi
            shift
            ;;
    esac
done

# --- PROMPT IF NOT PROVIDED ---
if [ -z "$SOURCE" ]; then
    printf "Enter source directory [default: %s]: " "$DEFAULT_SOURCE"
    read -r input_source
    SOURCE="${input_source:-$DEFAULT_SOURCE}"
fi

if [ -z "$BACKUP" ]; then
    printf "Enter destination directory [default: %s]: " "$DEFAULT_BACKUP"
    read -r input_backup
    BACKUP="${input_backup:-$DEFAULT_BACKUP}"
fi

# Expand tilde (~) if present and trim trailing slashes
SOURCE="${SOURCE/#\~/$HOME}"
BACKUP="${BACKUP/#\~/$HOME}"
SOURCE="${SOURCE%/}"
BACKUP="${BACKUP%/}"

# Determine the rsync binary location
if [ -f "/opt/homebrew/bin/rsync" ]; then
    RSYNC_BIN="/opt/homebrew/bin/rsync"
elif [ -f "/usr/local/bin/rsync" ]; then
    RSYNC_BIN="/usr/local/bin/rsync"
else
    RSYNC_BIN="rsync"
fi

# Detect supported progress flag (rsync 3+ supports --info=progress3; stock macOS rsync supports --progress)
if "$RSYNC_BIN" --help 2>&1 | grep -q -- '--info='; then
    PROGRESS_FLAG="--info=progress3"
else
    PROGRESS_FLAG="--progress"
fi
# ---------------------

echo "-----------------------------------------------"
echo "  🎧  SYNCING: $SOURCE/ -> $BACKUP/"
echo "-----------------------------------------------"

# 1. Safety Check: Ensure both directories exist
if [ ! -d "$SOURCE" ] || [ ! -d "$BACKUP" ]; then
    echo "❌ ERROR: Source or Destination folder not found!"
    [ ! -d "$SOURCE" ] && echo "   - Source missing: $SOURCE"
    [ ! -d "$BACKUP" ] && echo "   - Destination missing: $BACKUP"
    exit 1
fi

# 2. Sync files
# Exclude macOS system and indexing metadata
"$RSYNC_BIN" -rt --modify-window=5 \
    --delete --force \
    --inplace "$PROGRESS_FLAG" \
    --no-perms --no-owner --no-group \
    --exclude=".DS_Store" \
    --exclude=".Spotlight-V100" \
    --exclude=".Trashes" \
    --exclude=".TemporaryItems" \
    --exclude=".fseventsd" \
    --exclude="._*" \
    "$SOURCE/" "$BACKUP/"

echo "-----------------------------------------------"
echo "✨ SYNC COMPLETE! Directories are now identical."
afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true

if [ -t 0 ]; then
    echo ""
    echo "Press any key to close..."
    if [ -n "$ZSH_VERSION" ]; then
        read -k 1 -s -r
    else
        read -n 1 -s -r
    fi
fi