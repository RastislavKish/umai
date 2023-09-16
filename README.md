# umai

Ubuntu Mate is for long time known for its accessibility and convenience.

Still, after the system installation, there is a whole list of settings, tweaks and modifications that need to be done in order to get the system into the best shape for use with a screenreader.

It can be tedious even for an experienced user, and a beginner may find a series of configuration files edits, terminal commands and moving around the whole filesystem doing things they are not familiar with yet hard, error prone and even discouraging.

umai is a simple script specialized for Ubuntu Mate 22.04 that automatically performs the most common accessibility-related operations after the system installation. It can save time to seasoned users, and let the beginners focus on more interesting parts of their new OS.

## Usage

### When to use this script and when not

Warning! This script is intended to be used only and exclusively with ubuntu Mate 22.04, after completion of its installation and applying all available updates.

Usage with a different system, a different version or after doing other changes in the OS can lead to undefined behavior, messing the system at best.

A stable internet connection is also strongly recommended, since the script doesn't perform any checks of the results from the executed commands.

### Usage instructions

After finishing the system installation, perform all offered updates and follow the system's instructions.

When everything is ready, open the terminal by pressing the Super+T shortcut (or by typing terminal into the application search and clicking the icon).

Run the following commands:

```
sudo apt update
sudo apt install curl -y
curl -L -s https://github.com/RastislavKish/umai/releases/latest/download/umai.sh | bash
```

To download and launch the script from GitHub, or:

```
./umai.sh
```

If you get the script into your user directory (/home/username) by other means, like downloading via browser, bringing on a USB stick or copying from a network / USB drive.

Enter your user password if asked for, and wait until the script finishes. This can take few minutes.

You can tell the script has finished when pressing backspace in the terminal window plays a ping.

Log out and log in for all changes to take effect.

## The performed operations

Here is the list of operations the script currently applies

1. Enable Orca and the numlock key on the login screen by adding an Arctica greeter's scheme override.
2. Update Orca screenreader to its latest version from the [project's repository](https://gitlab.gnome.org/GNOME/orca).
3. Set ACCESSIBILITY_ENABLED environment variable to 1 in /etc/environment.
4. turn on the Mate's accessibility setting (org.mate.interface accessibility).
5. Install [ocrdesktop](https://github.com/chrys87/ocrdesktop) with all its Python and deb dependencies. The program is installed into /usr/local/bin and can be invoked by its name, making it easy to create a keyboard shortcut for it. The user is encouraged to install Tesseract language pack for their desired language by running sudo apt install tesseract-ocr-<lng>, where <lng> represents Tesseract's language code for a particular language.

