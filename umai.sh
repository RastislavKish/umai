# Copyright (C) 2022 Rastislav Kish
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

#!/usr/bin/sh

cd
mkdir .uma

# First, make sure everything is upto-date

sudo apt update
sudo apt upgrade -y

# Activate Orca and numlock on the login screen

echo Activating Orca and numlock on the login screen

echo \
'[org.ArcticaProject.arctica-greeter]
activate-numlock=true
screen-reader=true
' | sudo tee /usr/share/glib-2.0/schemas/99_arctica_greeter.gschema.override
sudo glib-compile-schemas /usr/share/glib-2.0/schemas

# Remove the snap firefox and install an apt-one

echo Replacing Firefox with an apt version

sudo snap remove firefox
sudo add-apt-repository ppa:mozillateam/ppa -y
echo \
'Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox
sudo apt update
sudo apt install firefox -y

# Install the latest Orca

echo Installing the latest orca

## Add site-packages as a symling to dist-packages

cd /usr/local/lib/python3.10
sudo ln -s dist-packages site-packages
cd

## Uncomment source repositories

sudo sed -i '/deb-src/s/^# //' /etc/apt/sources.list
sudo apt update

## Install git and clone the repository

sudo apt install git -y
cd ~/.uma
git clone https://gitlab.gnome.org/GNOME/orca.git
cd orca

## Install dependencies, build and upgrade Orca

sudo apt-get build-dep gnome-orca -y
PYTHON=/usr/bin/python3 ./autogen.sh
make
sudo make install

# Set the ACCESSIBILITY-ENABLED environment variable

echo Setting the ACCESSIBILITY_ENABLED flag

sudo sed -i '$ a ACCESSIBILITY_ENABLED=1' /etc/environment 

# Turn on Mate's accessibility setting

echo Turning on Mate's accessibility setting

gsettings set org.mate.interface accessibility true

# Install OCRDesktop

echo Installing OCRDesktop

sudo apt install python3-pip -y
sudo apt install tesseract-ocr libwnck-3-0 -y
pip3 install --upgrade pillow
pip3 install pdf2image pytesseract scipy webcolors

cd ~/.uma
git clone https://github.com/chrys87/ocrdesktop
cd ocrdesktop
sudo cp ocrdesktop /usr/local/bin

# Clean the downloaded files

echo Cleaning...

cd
rm -r -f .uma

