# usbsync

Fast, reliable script to synchronize files from one folder or USB drive to another on macOS using `rsync`.

## Features

- **Zero-Dependency & Portable**: Runs out of the box using built-in macOS tools, but automatically upgrades features if modern `rsync` 3.x is installed.
- **Finder Double-Click (`.command`)**: Non-technical users can simply double-click `usbsync.command` in Finder to run.
- **Interactive Prompts**: If paths are not provided, it prompts for source and destination, allowing you to press **Enter** to accept the defaults (`/Volumes/PRI` and `/Volumes/SEC`).
- **CLI Arguments & Flags**: Direct CLI usage via positional arguments or `-s`/`-d` flags.
- **Safe Exclusions**: Automatically excludes macOS system metadata (`.DS_Store`, `.Spotlight-V100`, `.Trashes`, etc.).
- **Audio Feedback**: Plays a chime upon completion.

---

## Prerequisites

### 1. Operating System
- **macOS** (Apple Silicon or Intel).

### 2. rsync (Optional but Recommended)
macOS comes with a built-in version of `rsync` located at `/usr/bin/rsync` (version 2.6.9), so **the script will work immediately with no installation required**.

However, **modern rsync 3.x+ is strongly recommended** for faster transfer speeds, lower memory usage, and enhanced real-time progress indicators.

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
If you use MacPorts:
```bash
sudo port install rsync
```

#### Option C: Built-in macOS Fallback
If you do not install a newer version, `usbsync` will automatically detect the stock macOS `rsync` and run using standard progress mode.

### 3. macOS Disk Permissions (If Prompted)
When accessing external USB drives for the first time, macOS may display a prompt asking for permission to access removable volumes or files. Click **Allow**. You can also manage permissions under **System Settings > Privacy & Security > Files and Folders**.

---

## How to Run

### Method 1: Double-Click (Best for non-technical users)
1. Double-click [`usbsync.command`](usbsync.command) in Finder.
2. Terminal will open and ask you to enter the source/destination folders (or press <kbd>Enter</kbd> to accept `/Volumes/PRI` and `/Volumes/SEC`).
3. Once finished, press any key to close the window.

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
