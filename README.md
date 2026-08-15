# usbsync

Fast, reliable script to synchronize files from one folder or USB drive to another on macOS using `rsync`.

## Features

- **Automatic USB & Drive Discovery**: Automatically detects plugged-in USB and external hard drives with volume names, sizes, and available free space.
- **Numbered Selection Menu**: Non-technical users don't need to know or type file paths—just pick a number (`1`, `2`, etc.) or hit <kbd>Enter</kbd> to accept defaults.
- **Drag & Drop Friendly**: Users can also drag and drop any folder directly from macOS Finder into the Terminal prompt.
- **Finder Double-Click (`.command`)**: Double-click `usbsync.command` to run without opening Terminal first.
- **CLI Arguments & Flags**: Direct CLI usage via positional arguments or `-s`/`-d` flags for advanced users or automation.
- **Safety Checks**: Prevents syncing a drive to itself and validates all directories before beginning.
- **Zero-Dependency & Portable**: Runs out of the box with built-in macOS tools; automatically upgrades features if modern `rsync` 3.x is installed.
- **Safe Exclusions**: Automatically excludes macOS system metadata (`.DS_Store`, `.Spotlight-V100`, `.Trashes`, etc.).
- **Audio Feedback**: Plays a chime upon completion.

---

## Prerequisites

### 1. Operating System
- **macOS** (Apple Silicon or Intel).

### 2. rsync (Optional but Recommended)
macOS includes a built-in version of `rsync` (`/usr/bin/rsync` v2.6.9), so **the script runs immediately with no setup required**.

However, **modern rsync 3.x+ is recommended** for faster transfer speeds and enhanced real-time progress indicators:

#### Option A: Install via Homebrew (Recommended)
If you do not have Homebrew installed:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Then install modern `rsync`:
```bash
brew install rsync
```

#### Option B: Install via MacPorts
```bash
sudo port install rsync
```

#### Option C: Built-in macOS Fallback
If neither is installed, `usbsync` automatically detects stock macOS `rsync` and runs smoothly.

### 3. macOS Disk Permissions (If Prompted)
When accessing external USB drives for the first time, macOS may ask for permission to access removable volumes or files. Click **Allow**. You can also manage permissions in **System Settings > Privacy & Security > Files and Folders**.

---

## How to Run

### Method 1: Double-Click (Best for non-technical users)
1. Double-click [`usbsync.command`](usbsync.command) in Finder.
2. The script will display all connected USB drives in a numbered list:
   ```
   -----------------------------------------------
     🔍  DETECTED EXTERNAL / USB DRIVES
   -----------------------------------------------
     [1] PRI (/Volumes/PRI) - 988.1 GB, 340.6 GB free
     [2] SEC (/Volumes/SEC) - 988.1 GB, 340.2 GB free
     [C] Custom Path / Other Folder (or Drag & Drop)
   -----------------------------------------------
   Select SOURCE (1-2, [C]ustom path, or Enter for [1 - /Volumes/PRI]): 
   Select DESTINATION (1-2, [C]ustom path, or Enter for [2 - /Volumes/SEC]): 
   ```
3. Type the number for each drive (or simply hit <kbd>Enter</kbd> to accept the defaults).
4. Once sync is complete, you'll hear a chime and can press any key to close the window.

### Method 2: Command Line (Interactive)
```bash
./usbsync.sh
```

### Method 3: Command Line (Direct Arguments / Flags)
```bash
# Positional arguments:
./usbsync.sh /Volumes/PRI /Volumes/SEC

# Named flags:
./usbsync.sh -s ~/Music -d /Volumes/Backup

# Help menu:
./usbsync.sh --help
```
