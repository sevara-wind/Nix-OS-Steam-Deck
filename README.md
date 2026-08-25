# 🎮 Jovian NixOS on Steam Deck (with Limine Bootloader)

This repository contains a reproducible declarative configuration for **NixOS** powered by the **Jovian-NixOS** project tailored for the **Steam Deck** handheld console. It utilizes a customized **Limine Bootloader** with background image support and a 90-degree hardware interface rotation.

---

## 🛠️ Table of Contents
1. [Repository Structure](#-repository-structure)
2. [Step-by-Step Installation Guide (Fresh Deployment)](#-step-by-step-installation-guide-fresh-deployment)
3. [System Reconstruction Guide (Subsequent Rebuilds)](#-system-reconstruction-guide-subsequent-rebuilds)
4. [GitHub Synchronization](#-github-synchronization)

---

## 📂 Repository Structure

* `configuration.nix` — Core system configuration file containing Jovian optimizations, GNOME desktop environment, hardware tweaks, and global system utilities.
* `flake.nix` — Pure declarative dependency definitions tracking the stable Nixpkgs and Jovian channels.
* `wallpaper.png` — Background image asset automatically bundled and hashed into the Limine boot splash menu.

---

## 🚀 Step-by-Step Installation Guide (Fresh Deployment)

Follow this comprehensive guide when installing NixOS from scratch on a new drive or restoring the system on your Steam Deck.

### Step 1: Boot and Partitioning
1. Boot your Steam Deck using a standard live NixOS installation USB drive.
2. Partition and format your storage drive according to standard Jovian guidelines. 
3. Ensure your main system root is mounted under `/mnt` and your EFI System Partition (ESP) is mounted under `/mnt/boot`.

### Step 2: Clone the Configuration Repository
Wipe any default placeholder configuration and clone this exact repository directly into the target installation directory:
```bash
sudo rm -rf /mnt/etc/nixos
sudo git clone https://github.com /mnt/etc/nixos
```

### Step 3: Fix Repository Ownership
To prevent Git from blocking operations due to user permissions (`dubious ownership`), add the directory to your safe list:
```bash
sudo git config --global --add safe.directory /mnt/etc/nixos
```

### Step 4: Generate Local Hardware Configuration
Generate the layout configuration unique to your specific drive setup:
```bash
sudo nixos-generate-config --root /mnt
```
*Note: This will safely generate `hardware-configuration.nix` inside `/mnt/etc/nixos` alongside your existing files without overwriting them.*

### Step 5: Perform the System Installation
Kick off the automated declarative system installation explicitly targeting your custom `steamdeck` Flake profile:
```bash
sudo nixos-install --flake /mnt/etc/nixos#steamdeck
```

---

## 🔄 System Reconstruction Guide (Subsequent Rebuilds)

Follow this routine whenever you modify your configurations on an already running system (e.g., adding new system packages, changing kernel arguments, or updating variables) to compile and activate changes on your device.

### Step-by-Step Rebuild Routine:

1. **Open your terminal and navigate to the workspace directory:**
   ```bash
   cd /etc/nixos
   ```

2. **Stage your file modifications in Git (Mandatory step for Nix Flakes):**
   *Crucial rule: Nix Flakes strictly restricts compiler access to tracked files only. If you modify `configuration.nix` or swap `wallpaper.png`, you MUST add them to the Git staging index. Otherwise, the compiler will completely ignore your changes and rebuild the old configuration state.*
   ```bash
   sudo git add configuration.nix
   ```

3. **Compile and execute the system reconstruction switch:**
   ```bash
   sudo nixos-rebuild switch --flake .#steamdeck
   ```

4. **Reboot the console:**
   ```bash
   sudo reboot
   ```

---

## ☁️ GitHub Synchronization

### Push local updates to GitHub:
```bash
cd /etc/nixos
sudo git add configuration.nix wallpaper.png README.md
sudo git commit -m "Update system configuration and installation documentation"
sudo git push origin main
```

### Pull remote updates to the Steam Deck:
```bash
cd /etc/nixos
sudo git pull origin main
sudo nixos-rebuild switch --flake .#steamdeck
```
