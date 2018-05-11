#!/bin/bash
#===============================================================================
# Copyright (C) 2018 Albert Steiner
# Author: Albert Steiner albert@alst.ovh
# 28/01/2018
#
# This file is free software you can redistribute it and/or modify
# it under the terms of the GNU General Public License (GPL)
# as published by the Free Software Foundation, in version 2
# It is distributed in the  hope that it will be useful,
# but WITHOUT ANY WARRANTY of any kind.
#===============================================================================

USER=`whoami`
VBPATH="/Users/$USER/Library/VBox"

if [ -f ~/Library/LaunchAgents/org.virtualbox.lockscreen.plist]; then
  launchctl unload ~/Library/LaunchAgents/org.virtualbox.lockscreen.plist
  rm ~/Library/LaunchAgents/org.virtualbox.lockscreen.plist
fi

if [ -f /Library/LaunchDaemons/org.virtualbox.vboxautostart.plist ]; then
  sudo launchctl unload /Library/LaunchDaemons/org.virtualbox.vboxautostart.plist
  sudo rm /Library/LaunchDaemons/org.virtualbox.vboxautostart.plist
fi

if [ -f /usr/local/bin/shutdown.sh ]; then
  sudo rm /usr/local/bin/shutdown.sh
fi
if [ -f /usr/local/bin/vbox.sh ]; then
  sudo rm /usr/local/bin/vbox.sh
fi

if [ ! -d $VBPATH ]; then
  rm -dr $VBPATH
fi

# PowerKey
if [ -f ~/Library/'Application Support'/com.pkamb.PowerKey/shutdownPowerKey.sh ]; then
  rm ~/Library/'Application Support'/com.pkamb.PowerKey/shutdownPowerKey.sh
fi

# Power Panel
if [ ! -d /etc/ppupsd ]; then
  sudo mkdir -p /etc/ppupsd
  sudo chown root:wheel /etc/ppupsd
  sudo chmod 755 /etc/ppupsd
fi

sudo cp -f \
  ppmac-shutdown.sh.org \
  /etc/ppupsd/ppmac-shutdown.sh

sudo chown root:wheel /etc/ppupsd/ppmac-shutdown.sh
sudo chmod 755 /etc/ppupsd/ppmac-shutdown.sh

# sudo
if [ -f /etc/sudoers.d/sudo_vboxshutdown ]; then
  sudo rm /etc/sudoers.d/sudo_vboxshutdown
fi

#===============================================================================
# End
#===============================================================================
