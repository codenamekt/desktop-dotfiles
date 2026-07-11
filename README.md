# Arch Desktop Dotfiles

This repository contains my desktop configurations for Labwc, Waybar, Rofi, Dunst, Swaync, and associated themes.

Managed using [GNU Stow](https://www.gnu.org/software/stow/).

## Setup and Installation

1. Install dependencies:
   ```bash
   sudo pacman -S stow
   ```

2. Clone this repository to `~/dotfiles`:
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

3. Stow the configurations:
   ```bash
   stow labwc waybar rofi dunst swaync themes
   ```
