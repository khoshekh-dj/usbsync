#!/bin/zsh

SCRIPT_NAME="$(basename "$0")"

# --- DEFAULT FALLBACKS ---
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
    echo "If SOURCE or DESTINATION are omitted, the script will discover"
    echo "connected USB drives and present a numbered selection menu."
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

# --- DISCOVER CONNECTED USB / EXTERNAL VOLUMES ---
detect_volumes() {
    VOL_NAMES=()
    VOL_PATHS=()
    VOL_DETAILS=()

    for vol in /Volumes/*; do
        [ -d "$vol" ] || continue
        [ -L "$vol" ] && continue
        
        info=$(diskutil info "$vol" 2>/dev/null) || continue
        name=$(echo "$info" | awk -F': *' '/Volume Name:/ {print $2}')
        size=$(echo "$info" | awk -F': *' '/Volume Total Space:/ {print $2}' | sed 's/ (.*//')
        free=$(echo "$info" | awk -F': *' '/Volume Free Space:/ {print $2}' | sed 's/ (.*//')

        [ -z "$name" ] && name="$(basename "$vol")"

        VOL_NAMES+=("$name")
        VOL_PATHS+=("$vol")
        VOL_DETAILS+=("$size, $free free")
    done
}

# --- PROMPT HELPER FOR VOLUME SELECTION ---
prompt_for_volume() {
    local label="$1"
    local def_path="$2"
    local def_num="$3"
    local selected_result=""

    while true; do
        if [ -n "$def_num" ]; then
            printf "Select %s (1-%d, [C]ustom path, or Enter for [%d - %s]): " \
                "$label" "${#VOL_PATHS[@]}" "$def_num" "$def_path"
        elif [ -n "$def_path" ]; then
            printf "Select %s (1-%d, [C]ustom path, or Enter for [%s]): " \
                "$label" "${#VOL_PATHS[@]}" "$def_path"
        else
            printf "Select %s (1-%d, or [C]ustom path): " "$label" "${#VOL_PATHS[@]}"
        fi

        read -r user_input

        # 1. User hit Enter -> use default
        if [ -z "$user_input" ]; then
            if [ -n "$def_path" ]; then
                SELECTED_PATH="$def_path"
                return 0
            else
                echo "❌ Please make a selection."
                continue
            fi
        fi

        # 2. User entered 'c' or 'custom'
        if [[ "$user_input" == "c" || "$user_input" == "C" || "$user_input" == "custom" ]]; then
            printf "👉 Enter custom %s path (or drag & drop folder here): " "$label"
            read -r custom_input
            custom_input="${custom_input/#\~/$HOME}"
            custom_input="${custom_input%\"}"
            custom_input="${custom_input#\"}"
            custom_input="${custom_input%\'}"
            custom_input="${custom_input#\'}"
            if [ -d "$custom_input" ]; then
                SELECTED_PATH="$custom_input"
                return 0
            else
                echo "❌ Directory not found: $custom_input"
                continue
            fi
        fi

        # 3. User entered a number matching one of the detected drives
        if [[ "$user_input" =~ ^[0-9]+$ ]] && [ "$user_input" -ge 1 ] && [ "$user_input" -le ${#VOL_PATHS[@]} ]; then
            SELECTED_PATH="${VOL_PATHS[$user_input]}"
            return 0
        fi

        # 4. User typed or dragged & dropped a path directly
        cleaned_path="${user_input/#\~/$HOME}"
        cleaned_path="${cleaned_path%\"}"
        cleaned_path="${cleaned_path#\"}"
        cleaned_path="${cleaned_path%\'}"
        cleaned_path="${cleaned_path#\'}"
        if [ -d "$cleaned_path" ]; then
            SELECTED_PATH="$cleaned_path"
            return 0
        fi

        # Fallback eval for escaped drag & drop paths
        eval_path="$(eval echo "$user_input" 2>/dev/null)"
        if [ -n "$eval_path" ] && [ -d "$eval_path" ]; then
            SELECTED_PATH="$eval_path"
            return 0
        fi

        echo "❌ Invalid choice: $user_input"
        echo "   Choose a number (1-${#VOL_PATHS[@]}), press Enter for default, or type 'c' for a custom path."
    done
}

# --- INTERACTIVE SELECTION IF NEEDED ---
if [ -z "$SOURCE" ] || [ -z "$BACKUP" ]; then
    detect_volumes

    if [ ${#VOL_PATHS[@]} -gt 0 ]; then
        echo "-----------------------------------------------"
        echo "  🔍  DETECTED EXTERNAL / USB DRIVES"
        echo "-----------------------------------------------"
        for i in {1..${#VOL_PATHS[@]}}; do
            echo "  [$i] ${VOL_NAMES[$i]} (${VOL_PATHS[$i]}) - ${VOL_DETAILS[$i]}"
        done
        echo "  [C] Custom Path / Other Folder (or Drag & Drop)"
        echo "-----------------------------------------------"

        # Determine smart defaults
        DEF_SRC_PATH=""
        DEF_SRC_NUM=""
        DEF_DST_PATH=""
        DEF_DST_NUM=""

        # Check for PRI / SEC
        for i in {1..${#VOL_PATHS[@]}}; do
            if [[ "${VOL_NAMES[$i]}" == "PRI" || "${VOL_PATHS[$i]}" == "/Volumes/PRI" ]]; then
                DEF_SRC_PATH="${VOL_PATHS[$i]}"
                DEF_SRC_NUM="$i"
            elif [[ "${VOL_NAMES[$i]}" == "SEC" || "${VOL_PATHS[$i]}" == "/Volumes/SEC" ]]; then
                DEF_DST_PATH="${VOL_PATHS[$i]}"
                DEF_DST_NUM="$i"
            fi
        done

        # Fallback: Drive 1 -> Source, Drive 2 -> Destination if not already assigned
        if [ -z "$DEF_SRC_NUM" ] && [ ${#VOL_PATHS[@]} -ge 1 ]; then
            DEF_SRC_PATH="${VOL_PATHS[1]}"
            DEF_SRC_NUM="1"
        fi
        if [ -z "$DEF_DST_NUM" ] && [ ${#VOL_PATHS[@]} -ge 2 ]; then
            DEF_DST_PATH="${VOL_PATHS[2]}"
            DEF_DST_NUM="2"
        fi

        # Prompt for Source
        if [ -z "$SOURCE" ]; then
            prompt_for_volume "SOURCE" "$DEF_SRC_PATH" "$DEF_SRC_NUM"
            SOURCE="$SELECTED_PATH"
        fi

        # Prompt for Destination
        if [ -z "$BACKUP" ]; then
            prompt_for_volume "DESTINATION" "$DEF_DST_PATH" "$DEF_DST_NUM"
            BACKUP="$SELECTED_PATH"
        fi
    else
        echo "⚠️  No external USB drives detected."
        
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
    fi
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

echo ""
echo "-----------------------------------------------"
echo "  🎧  SYNCING: $SOURCE/ -> $BACKUP/"
echo "-----------------------------------------------"

# Safety Check 1: Ensure both directories exist
if [ ! -d "$SOURCE" ] || [ ! -d "$BACKUP" ]; then
    echo "❌ ERROR: Source or Destination folder not found!"
    [ ! -d "$SOURCE" ] && echo "   - Source missing: $SOURCE"
    [ ! -d "$BACKUP" ] && echo "   - Destination missing: $BACKUP"
    exit 1
fi

# Safety Check 2: Ensure source and destination are not identical
if [ "$SOURCE" = "$BACKUP" ]; then
    echo "❌ ERROR: Source and Destination cannot be the same directory!"
    echo "   Both are set to: $SOURCE"
    exit 1
fi

# Sync files
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