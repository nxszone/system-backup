# System Backup and Restore Scripts
This repository contains two shell scripts, `backup.sh` and `restore.sh`, designed for Linux users to easily backup and restore their system configurations. These scripts are useful for anyone who frequently switches or updates their operating system and wants a simple way to backup and restore their custom settings, profiles, and configurations.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Backup Script](#backup-script)
- [Restore Script](#restore-script)
---

## Features
### `backup.sh`:
- Backups system configurations, dotfiles, browser profiles, application settings, SSH keys, package lists, fonts, and custom scripts.
- Option to backup specific parts of the system or everything with a single command using command-line arguments.
- Creates a timestamped directory to store backup files and generates a compressed `.tar.gz` file for portability.
  
### `restore.sh`:
- Restores backup files from `.tar.gz` archives or uncompressed backup directories.
- Supports restoring specific parts of the system (dotfiles, browsers, apps, SSH, packages, etc.).
- Handles the reinstallation of packages (Debian, Arch, Flatpak, Snap) from backup lists.


## Installation

1. Clone the repository to your local machine:
```bash
git clone https://github.com/nxszone/system-backup.git
cd system-backup
```

2. Make both scripts executable:
```bash
chmod +x backup.sh restore.sh
```
  
## Usage
### Backup Script
The `backup.sh` script is used to create backups of your system's settings, preferences, browser profiles, and more.

```bash
./backup.sh [options]
```
#### Available Options
-   `-d`: Backup dotfiles (e.g., `.bashrc`, `.vimrc`, `.zshrc`, etc.)
-   `-b`: Backup browser profiles (e.g., Mozilla, Chrome, Chromium, Brave)
-   `-a`: Backup application settings (e.g., VS Code, Spotify, Discord)
-   `-s`: Backup SSH keys
-   `-p`: Backup package lists (Debian, Arch, Flatpak, Snap)
-   `-f`: Backup fonts
-   `-c`: Backup custom scripts
-   `-all`: Backup everything (dotfiles, browsers, apps, SSH, packages, fonts, scripts)


#### Example Usage:
1.  To backup only dotfiles and browser profiles:
	```bash
	./backup.sh -d -b`
	```
3.  To backup everything:
    ```bash
    ./backup.sh -all
	 ```
4.  To backup SSH keys and applications:
    ```bash
    ./backup.sh -s -a
    ```
    
The backup will be stored in a directory with the current timestamp, and the entire backup will be compressed into a `.tar.gz` file.


### Restore Script

The `restore.sh` script is used to restore backups from a `.tar.gz` archive or an uncompressed directory.

```bash
./restore.sh <backup_file_or_directory> [options]
```
#### Available Options:
-   `-d`: Restore dotfiles
-   `-b`: Restore browser profiles
-   `-a`: Restore application settings
-   `-s`: Restore SSH keys
-   `-p`: Restore package lists (Debian, Arch, Flatpak, Snap)
-   `-f`: Restore fonts
-   `-c`: Restore custom scripts
-   `-all`: Restore everything (dotfiles, browsers, apps, SSH, packages, fonts, scripts)


#### Example Usage:
1.  To restore everything from a `.tar.gz` backup:
    ```bash
    ./restore.sh system_backup_20231119_123456.tar.gz -all
    ```
2.  To restore only dotfiles and SSH keys:
    ```bash
    ./restore.sh system_backup_20231119_123456/ -d -s
    ```
3.  To restore specific directories (e.g., fonts and custom scripts):
```bash
./restore.sh system_backup_20231119_123456/ -f -c

If you provide a `.tar.gz` backup file, it will be extracted temporarily before restoring the files. If you provide a directory, it will restore from that directory directly.
