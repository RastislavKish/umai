#!/usr/bin/bash

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

. /etc/os-release

if ! [[ "$NAME" == "Ubuntu" ]]; then
echo 'Error: The UMAI script can only be used on Ubuntu Mate version 22.04 | 23.04'
exit 1
fi

if ! [[ "$VERSION" =~ ^(22\.04|23\.04|23\.10|24\.04).*$ ]]; then
echo 'Error: The UMAI script can only be used on Ubuntu Mate version 22.04 | 23.04 | 23.10 | 24.04'
exit 1
fi

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

# Install the latest Orca

echo Installing the latest orca

# Fix problems with installation target directories

if [[ "$VERSION" =~ ^22\.04.*$ ]]; then
## Add site-packages as a symling to dist-packages

cd /usr/local/lib/python3.*
sudo ln -s dist-packages site-packages
cd

elif [[ "$VERSION" =~ ^(23\.04|23\.10).*$ ]]; then

# We need to workaround https://bugs.launchpad.net/ubuntu/+source/python3.11/+bug/2052443 fixed in UM 24.04
sudo mkdir -p /usr/local/local/lib/python3.11
sudo ln -s /usr/local/lib/python3.11/dist-packages /usr/local/local/lib/python3.11/dist-packages

fi

## Uncomment source repositories

if [[ "$VERSION" =~ ^(22\.04|23\.04|23\.10).*$ ]]; then
sudo sed -i '/deb-src/s/^# //' /etc/apt/sources.list
elif [[ "$VERSION" =~ ^(24\.04).*$ ]]; then
# UM 24.04 configures source repos in a different way
sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources*

fi

sudo apt update

## Install git and clone the repository

sudo apt install git -y
cd ~/.uma
git clone https://gitlab.gnome.org/GNOME/orca.git
cd orca

## Install dependencies, build and upgrade Orca

if [[ "$VERSION" =~ ^22\.04.*$ ]]; then

git switch gnome-44
sudo apt-get build-dep gnome-orca -y

PYTHON=/usr/bin/python3 ./autogen.sh
make
sudo make install

elif [[ "$VERSION" =~ ^(23\.04|23\.10|24\.04).*$ ]]; then

git switch gnome-46
sudo apt install meson -y
sudo apt-get build-dep orca -y

meson setup _build
meson compile -C _build
sudo meson install -C _build

fi

# Set the ACCESSIBILITY-ENABLED environment variable

echo Setting the ACCESSIBILITY_ENABLED flag

sudo sed -i '$ a ACCESSIBILITY_ENABLED=1' /etc/environment 

# Turn on Mate's accessibility setting

echo Turning on Mate\'s accessibility setting

gsettings set org.mate.interface accessibility true

# Install OCRDesktop

echo Installing OCRDesktop

sudo apt install python3-pip python3-venv -y
sudo apt install tesseract-ocr libwnck-3-0 -y

cd ~/.uma

git clone https://github.com/chrys87/ocrdesktop ocrdesktop-repo

mkdir -p ocrdesktop
python3 -m venv --system-site-packages ocrdesktop/venv
cp ocrdesktop-repo/ocrdesktop ocrdesktop

cd ocrdesktop
. venv/bin/activate

pip3 install --upgrade pillow
pip3 install pdf2image pytesseract scipy webcolors

deactivate

cd ..
sudo cp -r ocrdesktop /usr/local/lib

echo \
'#!/usr/bin/bash

. /usr/local/lib/ocrdesktop/venv/bin/activate
/usr/local/lib/ocrdesktop/venv/bin/python3 /usr/local/lib/ocrdesktop/ocrdesktop "$@"
' | sudo tee /usr/local/bin/ocrdesktop

sudo chmod +x /usr/local/bin/ocrdesktop

# Clean the downloaded files

echo Cleaning...

cd
rm -r -f .uma

