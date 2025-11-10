# Cron Manager

A simple GUI application for managing cron jobs in Linux, built with Bash and Zenity.

![Cron Manager](screenshot.png)

## Features

- 📋 **View cron jobs** - List all active cron jobs with human-readable schedules
- ➕ **Add cron jobs** - Easy form-based input for new cron jobs
- ⚡ **Quick add presets** - Templates for common schedules (hourly, daily, weekly, etc.)
- 🗑️ **Delete/Disable jobs** - Remove or temporarily disable cron jobs
- 💾 **Auto backup** - Automatic backup before any changes
- 🔄 **Restore backups** - Restore crontab from previous backups
- 📄 **View raw crontab** - Display raw crontab content
- 🎨 **Native GUI** - GTK-based interface using Zenity

## Prerequisites

- **zenity** - GUI dialog boxes
- **cron/cronie** - Cron daemon

The installation script will automatically detect your distro and install these dependencies.

## Supported Distributions

- ✅ Arch Linux and derivatives (Manjaro, EndeavourOS, CachyOS, ArcoLinux, etc.)
- ✅ Debian and derivatives (Ubuntu, Linux Mint, Pop!_OS, Elementary, KDE Neon, etc.)
- ✅ Fedora
- ✅ OpenSUSE
- ✅ Any distro with pacman, apt, dnf, or zypper package manager

## Installation

### Quick install (Recommended)

```bash
git clone https://github.com/yourusername/cronmanager.git
cd cronmanager
sudo make install
```

The installation script will:
1. Auto-detect your Linux distribution
2. Install required dependencies (zenity, cron)
3. Enable and start cron service
4. Copy script to `/usr/bin/cronmanager`
5. Install desktop entry

### Manual installation

If automatic installation fails:

```bash
# Install dependencies manually
# For Arch: sudo pacman -S zenity cronie
# For Debian/Ubuntu: sudo apt install zenity cron
# For Fedora: sudo dnf install zenity cronie

# Make script executable
chmod +x cronmanager.sh

# Copy to system bin
sudo cp cronmanager.sh /usr/bin/cronmanager
sudo chmod a+rx /usr/bin/cronmanager

# Install desktop entry
sudo cp cronmanager.desktop /usr/share/applications/
```

## Usage

### From terminal
```bash
cronmanager
```

### From application menu
Search for "Cron Manager" in your applications menu

## Makefile commands

```bash
make install      # Install to system
make uninstall    # Remove from system
make check        # Check installation status
make clean        # Clean temporary files
make help         # Show help
```

## File locations

- **Binary:** `/usr/local/bin/cronmanager`
- **Desktop entry:** `/usr/local/share/applications/cronmanager.desktop`
- **Backups:** `~/.config/cronmanager/backups/`

## Screenshots

### Main Menu
![Main Menu](screenshots/main-menu.png)

### Add Cron Job
![Add Job](screenshots/add-job.png)

### View Jobs
![View Jobs](screenshots/view-jobs.png)

## Quick Add Presets

- **Every hour** - `0 * * * *`
- **Every day at midnight** - `0 0 * * *`
- **Every day at 7 AM** - `0 7 * * *`
- **Every day at 5 PM** - `0 17 * * *`
- **Every Monday at 9 AM** - `0 9 * * 1`
- **First day of month** - `0 0 1 * *`

## Examples

### Open YouTube NASA live stream at 5 PM daily
1. Select "⚡ Quick Add (Presets)"
2. Choose "Every day at 5 PM"
3. Enter command: `xdg-open "https://www.youtube.com/watch?v=21X5lGlDOfg"`

### Close browser and open new page at 7 AM daily
1. Select "⚡ Quick Add (Presets)"
2. Choose "Every day at 7 AM"
3. Enter command: `pkill chrome && xdg-open "https://livecounts.io/..."`

## Backup System

Cron Manager automatically creates backups before any modifications:
- Backups are stored in `~/.config/cronmanager/backups/`
- Backup files are named with timestamp: `crontab_YYYYMMDD_HHMMSS.txt`
- Use "💾 Restore Backup" to restore previous versions

## Troubleshooting

### Zenity not found
```bash
# Install zenity first
sudo apt install zenity  # Ubuntu/Debian
```

### Crontab command not found
```bash
# Install cron
sudo apt install cron  # Ubuntu/Debian
sudo systemctl enable --now cron
```

### Permission denied
```bash
# Make script executable
chmod +x cronmanager.sh

# Or reinstall
sudo make uninstall
sudo make install
```
