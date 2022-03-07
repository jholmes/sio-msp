#!/usr/bin/env bash

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

git --version > /dev/null 2>&1
GIT_IS_AVAILABLE=$?

python3 --version > /dev/null 2>&1
PYTHON3_IS_AVAILABLE=$?

DOCKER_IS_AVAILABLE=0
if [[ $(which docker) && $(docker --version) ]]; then
    DOCKER_IS_AVAILABLE=1
fi

NEEDS_INSTALL=0

PACKAGESNEEDED=
if [ $GIT_IS_AVAILABLE -eq 0 ]; then
  echo "Git is not installed on this system."
  PACKAGESNEEDED='git '
  NEEDS_INSTALL=1
fi
if [ $PYTHON3_IS_AVAILABLE -eq 0 ]; then
  echo "Python3 is not installed on this system."
  PACKAGESNEEDED="${PACKAGESNEEDED}python3 "
  NEEDS_INSTALL=1
fi
if [ $DOCKER_IS_AVAILABLE -eq 0 ]; then
  echo "Docker is not installed on this system."
  PACKAGESNEEDED="${PACKAGESNEEDED}docker "
  NEEDS_INSTALL=1
fi

if [ $NEEDS_INSTALL -eq 1 ]; then
  if [[ $OSTYPE == 'linux'* ]]; then
    if [ -x "$(command -v apk)" ];       then GIT_INSTALL_CMD="sudo apk add --no-cache $PACKAGESNEEDED"
    elif [ -x "$(command -v apt-get)" ]; then GIT_INSTALL_CMD="sudo apt-get install $PACKAGESNEEDED"
    elif [ -x "$(command -v dnf)" ];     then GIT_INSTALL_CMD="sudo dnf install $PACKAGESNEEDED"
    elif [ -x "$(command -v yum)" ];     then GIT_INSTALL_CMD="sudo yum install $PACKAGESNEEDED"
    elif [ -x "$(command -v zypper)" ];  then GIT_INSTALL_CMD="sudo zypper install $PACKAGESNEEDED"
    else
      echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: $PACKAGESNEEDED">&2;
      exit
    fi
  elif [[ $OSTYPE == 'darwin'* ]]; then
    brew -v > /dev/null 2>&1
    BREW_IS_AVAILABLE=$?
    port version > /dev/null 2>&1
    MACPORTS_IS_AVAILABLE=$?

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
      No ) echo "CANNOT PROCEED: Missing packages, ${PACKAGESNEEDED}, are necessary to continue. Exiting."; exit;;
    esac
  done
fi

git clone https://github.com/jholmes/sio-msp.git
