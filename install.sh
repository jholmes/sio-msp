#!/bin/bash

VER=0.9

echo "/------------------------------------------------------------------"
echo "/ SIO Marine Seismic Processing Package Installer"
echo "/"
echo "/ This script will confirm that you have Git, Python3, and Docker"
echo "/ installed. If they aren't found, it will prompt you to install."
echo "/"
echo "/ Version ${VER}. Licensed under GNU GPL3."
echo "/ (c) 2022, UC San Diego, jjholmes@ucsd.edu"
echo "/------------------------------------------------------------------"
echo ""

case "$OSTYPE" in
  linux*)   echo "System detected: Linux / WSL" ;;
  darwin*)  echo "System detected: Mac OS" ;;
  win*)     echo "System detected: Windows" ;;
  msys*)    echo "System detected: MSYS / MinGW / Git Bash" ;;
  cygwin*)  echo "System detected: Cygwin" ;;
  bsd*)     echo "System detected: BSD" ;;
  solaris*) echo "System detected: Solaris" ;;
  *)        echo "System detected: unknown ($OSTYPE)" ;;
esac

NEEDS_INSTALL=0

if ! [ -x "$(command -v git)" ]; then
  PACKAGES_NEEDED='git '
  NEEDS_INSTALL=1
  echo "Git is not installed on this system."
fi

if ! [ -x "$(command -v python3)" ]; then
  PACKAGES_NEEDED="${PACKAGES_NEEDED}python3 "
  NEEDS_INSTALL=1
  echo "Python3 is not installed on this system."
fi

if ! [ -x "$(command -v docker)" ]; then
  PACKAGES_NEEDED="${PACKAGES_NEEDED}docker "
  NEEDS_INSTALL=1
  echo "Docker is not installed on this system."
fi

echo ""

if [ $NEEDS_INSTALL -eq 1 ]; then
  if [[ $OSTYPE == 'linux'* ]]; then
    if [ -x "$(command -v apk)" ];       then GIT_INSTALL_CMD="sudo apk add --no-cache $PACKAGES_NEEDED"
    elif [ -x "$(command -v apt-get)" ]; then GIT_INSTALL_CMD="sudo apt-get install $PACKAGES_NEEDED"
    elif [ -x "$(command -v dnf)" ];     then GIT_INSTALL_CMD="sudo dnf install $PACKAGES_NEEDED"
    elif [ -x "$(command -v yum)" ];     then GIT_INSTALL_CMD="sudo yum install $PACKAGES_NEEDED"
    elif [ -x "$(command -v zypper)" ];  then GIT_INSTALL_CMD="sudo zypper install $PACKAGES_NEEDED"
    else
      echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: $PACKAGES_NEEDED">&2;
      exit
    fi
  elif [[ $OSTYPE == 'darwin'* ]]; then
    BREW_IS_AVAILABLE=1
    if ! [ -x "$(command -v brew)" ]; then
      BREW_IS_AVAILABLE=0
    fi

    MACPORTS_IS_AVAILABLE=1
    if ! [ -x "$(command -v port)" ]; then
      MACPORTS_IS_AVAILABLE=0
    fi

    if [ $BREW_IS_AVAILABLE -eq 1 ]; then
      echo "Homebrew is available."
      GIT_INSTALL_CMD="brew install git"
    elif [ $MACPORTS_IS_AVAILABLE -eq 1 ]; then
      echo "MacPorts is available."
      GIT_INSTALL_CMD="sudo port install git"
    else
      echo "FAILED TO INSTALL PACKAGE: Package manager not found. Please install either Macports or Homebrew, then "
      echo "install Git using one of them."
      exit
    fi
  fi
  echo "Would you like to install missing packages? [y/n]: "
  select yn in "Yes" "No"; do
    case $yn in
      Yes ) $GIT_INSTALL_CMD; break;;
      No ) echo "CANNOT PROCEED: Missing packages, ${PACKAGES_NEEDED}, are necessary to continue. Exiting."; exit;;
    esac
  done
fi

git clone https://github.com/jholmes/sio-msp.git
echo ""
echo "Preparing Python environment..."
cd sio-msp
mkdir data
chmod a+x ./start-msp
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "/------------------------------------------------------------------"
echo "/ Finished installation."
echo "/"
echo "/ Next, run the start-msp script to process files:"
echo "/ $ cd sio-msp"
echo "/ $ ./start-msp -f <SEG-Y file>"
echo "/------------------------------------------------------------------"