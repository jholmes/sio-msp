#!/usr/bin/env bash

VER=0.9

echo "/----------------------------------------"
echo "/ SIO Marine Seismic Processing Package"
echo "/"
echo "/ This script will confirm that you have Git and Python3 installed."
echo "/"
echo "/ Version ${VER}. Licensed under GNU GPL3."
echo "/ (c) UC San Diego, jjholmes@ucsd.edu"
echo "/----------------------------------------"

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

git --version 2>&1 >/dev/null
GIT_IS_AVAILABLE=$?

python3 --version 2>&1 >/dev/null
PYTHON3_IS_AVAILABLE=$?

NEEDS_INSTALL=0

packagesNeeded=
if [ $GIT_IS_AVAILABLE -eq 0 ]; then
  echo "Git is not installed on this system."
  packagesNeeded='git '
  $NEEDS_INSTALL=1
fi
if [ $PYTHON3_IS_AVAILABLE -eq 0 ]; then
  echo "Python3 is not installed on this system."
  packagesNeeded="${packagesNeeded}python3"
  $NEEDS_INSTALL=1
fi

if [ $NEEDS_INSTALL -eq 1]; then
  if [[ $OSTYPE == 'linux'* ]]; then
    if [ -x "$(command -v apk)" ];       then GIT_INSTALL_CMD="sudo apk add --no-cache $packagesNeeded"
    elif [ -x "$(command -v apt-get)" ]; then GIT_INSTALL_CMD="sudo apt-get install $packagesNeeded"
    elif [ -x "$(command -v dnf)" ];     then GIT_INSTALL_CMD="sudo dnf install $packagesNeeded"
    elif [ -x "$(command -v yum)" ];     then GIT_INSTALL_CMD="sudo yum install $packagesNeeded"
    elif [ -x "$(command -v zypper)" ];  then GIT_INSTALL_CMD="sudo zypper install $packagesNeeded"
    else
      echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: $packagesNeeded">&2;
      exit
    fi
  elif [[ $OSTYPE == 'darwin'* ]]; then
    brew -v >/dev/null 2>&1
    BREW_IS_AVAILABLE=$?
    port version >/dev/null 2>&1
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
  echo "Would you like to install Git? [y/n]: "
  select yn in "Yes" "No"; do
    case $yn in
      Yes ) $GIT_INSTALL_CMD; break;;
      No ) echo "Git is necessary to proceed. Quitting."; exit;;
    esac
  done
fi











