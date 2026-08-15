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

## 🎛️ Prerequisites

### 1. 💻 Operating System
- **macOS** (Apple Silicon M1/M2/M3/M4 or Intel).

### 2. ⚡ rsync *(Optional but Recommended)*
macOS comes pre-installed with `rsync` (`/usr/bin/rsync` v2.6.9), so **`usbsync` works immediately out of the box with zero installations**.

For the ultimate speed and modern progress bars, **Homebrew `rsync` 3.x+** is recommended:

```bash
# Install Homebrew (if you don't have it):
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install modern rsync:
brew install rsync
```

*(If you don't have Homebrew, `usbsync` automatically uses the built-in macOS engine.)*

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

<p align="center">
  <b>🎵 Keep the music playing & never get caught without a backup drive! 🎧</b>
</p>
