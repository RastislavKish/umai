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

if ! [[ "$VERSION" =~ ^(22\.04|23\.04|23\.10).*$ ]]; then
echo 'Error: The UMAI script can only be used on Ubuntu Mate version 22.04 | 23.04 | 23.10'
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

## Add site-packages as a symling to dist-packages

cd /usr/local/lib/python3.*
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

if [[ "$VERSION" =~ ^22\.04.*$ ]]; then

git switch gnome-44
sudo apt-get build-dep gnome-orca -y

elif [[ "$VERSION" =~ ^(23\.04|23\.10).*$ ]]; then

git switch gnome-45
sudo apt-get build-dep orca -y

fi

PYTHON=/usr/bin/python3 ./autogen.sh
make
sudo make install

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

