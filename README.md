# 🎧 usbsync ⚡

> **Lightning-fast, zero-stress USB mirroring for DJs & creators on macOS.**  
> Keep your Primary (`PRI`) and Secondary/Backup (`SEC`) USB sticks 100% identical and gig-ready in seconds.

```text
 🎛️ Plug In  ──▶  💿 Auto-Detect Drives  ──▶  ⚡ Fast Differential Sync  ──▶  🎶 100% Gig-Ready!
```

---

## 🚀 Why DJs Use `usbsync`

Exporting playlists from **rekordbox** or **Engine DJ** to two separate USBs can take ages. Re-exporting an entire 128GB–1TB drive just for a few new tracks wastes valuable prep time before a gig.

`usbsync` uses incremental `rsync` mirroring to solve this:
- ⚡ **Lightning Fast**: Only copies newly added tracks and updated cue point / beatgrid databases (`export.pdb`, `master.dat`, `PIONEER/`, etc.). Syncs in seconds instead of hours!
- 🧹 **Clean Deletions**: Automatically removes tracks from your backup drive that you deleted from your primary drive.
- 🛡️ **CDJ-Safe Exclusions**: Prevents macOS from writing junk system files (`.DS_Store`, `.Spotlight-V100`, `.Trashes`) that can slow down or crash hardware players.
- 🔊 **Audio Chime**: Plays a victory sound once your drives are completely synced and ready for the club.

---

## ✨ Features

- 🔍 **Auto USB Discovery**: Scans and displays all plugged-in USBs and external drives with volume labels and free space.
- 🔢 **No Typing Required**: Pick your drives with simple numbers (`1`, `2`) or press <kbd>Enter</kbd> to accept smart defaults.
- 🖱️ **Double-Click & Go (`.command`)**: Non-technical users can just double-click [`usbsync.command`](usbsync.command) straight from macOS Finder.
- 📂 **Finder Drag & Drop**: Drag and drop any custom playlist or folder right into the terminal window.
- 🎚️ **Pro CLI Arguments**: Supports positional paths and `-s` / `-d` flags for automated workflows.
- 🛑 **Accident-Proof**: Safety checks prevent you from accidentally syncing a drive onto itself.
- 📦 **Zero-Install Ready**: Works out of the box with stock macOS tools, with automatic enhancements for Homebrew `rsync`.

---

## 📥 Download & First-Time Setup

### 1. Download
1. Go to the **[GitHub Releases](https://github.com/khoshekh-dj/usbsync/releases)** page.
2. Under the latest release, download the **Source code (.zip)** file.
3. Double-click the downloaded zip file in your `Downloads` folder to extract it.

---

### 2. macOS First-Time Gatekeeper Fix

When you download scripts in a zip file from the internet, modern macOS (Sonoma / Sequoia) automatically blocks execution with this security warning:

> ⛔ **“usbsync.command” Not Opened**  
> *Apple could not verify “usbsync.command” is free of malware that may harm your Mac or compromise your privacy.*

Because Apple removed the old "Right-Click Open" bypass for downloaded scripts, choose **one** of the two easy methods below to authorize it:

#### Method A: Via macOS System Settings *(No Terminal required)*
1. Double-click [`usbsync.command`](usbsync.command) once (it will show the blocked warning). Click **Done**.
2. Open **System Settings** on your Mac.
3. Go to **Privacy & Security** and scroll down to the **Security** section.
4. You will see: *"usbsync.command was blocked from use because it is not from an identified developer."*
5. Click **Open Anyway**, enter your Mac password or Touch ID, and click **Open**.
6. *(You only need to do this once. Afterwards, you can double-click it directly anytime!)*

---

#### Method B: One-Liner in Terminal *(Instant unlock & permissions fix)*
If you prefer a 2-second command, open Terminal, paste this single line, and press <kbd>Enter</kbd>:

```bash
cd ~/Downloads/usbsync* && xattr -cr . && chmod +x *.command *.sh
```

*(This strips the macOS quarantine flag and ensures the file is executable).*

---

#### 💡 Alternative: Clone with Git *(Bypasses macOS quarantine completely)*
If you clone via Git instead of downloading a zip, macOS will never quarantine the files:
```bash
git clone https://github.com/khoshekh-dj/usbsync.git
```
*(No Homebrew needed for this either. If `git` isn't installed yet, macOS offers to install Apple's free **Command Line Tools** the first time you run it. Click **Install**, or run `xcode-select --install`. If you'd rather not install anything, use the zip download above.)*

---

## 🎛️ Prerequisites

### 1. 💻 Operating System
- **macOS** (Apple Silicon M1/M2/M3/M4 or Intel).

### 2. ⚡ rsync *(Already on your Mac — nothing to install)*
Every Mac ships with `rsync` at `/usr/bin/rsync`, so **`usbsync` works out of the box with zero installations. You do *not* need Homebrew.**

Everything else the script uses (`zsh`, `diskutil`, `afplay`) is also built into macOS.

#### 🍏 No Homebrew? No problem.
If you've never heard of Homebrew, just skip this section. `usbsync` automatically detects that Homebrew isn't installed and uses the built-in macOS `rsync`. Your drives are mirrored exactly the same way:
- ✅ New and changed tracks are copied
- ✅ Deleted tracks are removed from the backup
- ✅ macOS junk files (`.DS_Store`, `._*`, etc.) are skipped

The only difference you'll notice is the progress display: the built-in version shows progress **per file**, and Homebrew `rsync` shows a single overall progress line.

To confirm the built-in `rsync` is there, open **Terminal** and run:
```bash
/usr/bin/rsync --version
```
*(On macOS 15.4 Sequoia and later, this shows `openrsync … rsync version 2.6.9 compatible`. On older macOS, it shows `rsync version 2.6.9`. Both work with `usbsync`.)*

#### 🍺 Optional Upgrade: Homebrew `rsync` 3.x+
If you already use [Homebrew](https://brew.sh), or want the nicer overall progress bar, you can install modern `rsync`:

```bash
# Install Homebrew (only if you want it):
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install modern rsync:
brew install rsync
```

`usbsync` picks it up automatically from `/opt/homebrew/bin/rsync` (Apple Silicon) or `/usr/local/bin/rsync` (Intel). You don't need to change any settings.

### 3. 🔐 macOS Disk Permissions *(If Prompted)*
When accessing your USB drives for the first time, macOS may ask: *"Terminal would like to access files on a removable volume"*. Click **Allow** (or configure in **System Settings > Privacy & Security > Files and Folders**).

---

## 💿 How to Run

### Method 1: 🖱️ Double-Click in Finder *(Easiest)*
1. Double-click [`usbsync.command`](usbsync.command) in Finder.
2. The script displays your detected drives:
   ```text
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
3. Press <kbd>Enter</kbd> twice to accept defaults, or choose your drive numbers.
4. Listen for the completion chime 🔔 and you're good to hit the decks! 🎧

---

### Method 2: 💻 Command Line (Interactive)
```bash
./usbsync.sh
```

---

### Method 3: 🎚️ Command Line (Direct Flags & Paths)
```bash
# Sync by positional paths:
./usbsync.sh /Volumes/PRI /Volumes/SEC

# Sync using flags:
./usbsync.sh -s ~/Music -d /Volumes/SEC

# View full help & options:
./usbsync.sh --help
```

---

## ⚠️ Disclaimer

> **Use at your own risk.**  
> This script performs direct synchronization with file deletion (`--delete`) to mirror files from source to destination. Any data loss, file corruption, or hardware damage resulting from the use or misuse of this software is solely at the user's own risk. Always maintain a separate, secure backup of your master music library before running any synchronization tools.

---

<p align="center">
  <b>🎵 Keep the music playing & never get caught without a backup drive! 🎧</b>
</p>
