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

if [ ! -d $VBPATH ]; then
  mkdir $VBPATH
fi

cp -f \
  shutdown.aiff \
  $VBPATH

cp -f \
  vboxsettings \
  $VBPATH
sed -i '' "s|VBPATH|$VBPATH|" $VBPATH/vboxsettings
sed -i '' "s/VBOXUSER/$USER/" $VBPATH/vboxsettings
chmod 754 $VBPATH/vboxsettings

cp -f \
  _shutdown.sh \
  $VBPATH/shutdown.sh
sed -i '' "s|VBPATH|$VBPATH|" $VBPATH/shutdown.sh
chmod 754 $VBPATH/shutdown.sh

cp -f \
  _vbox.sh \
  $VBPATH/vbox.sh
sed -i '' "s|VBPATH|$VBPATH|" $VBPATH/vbox.sh
chmod 754 $VBPATH/vbox.sh

cp -f \
  _vboxautostart.sh \
  $VBPATH/vboxautostart.sh
sed -i '' "s|VBPATH|$VBPATH|" $VBPATH/vboxautostart.sh
chmod 754 $VBPATH/vboxautostart.sh

cp -f \
  _vboxvmscfg.sh \
  $VBPATH/vboxvmscfg.sh
sed -i '' "s|VBPATH|$VBPATH|" $VBPATH/vboxvmscfg.sh
chmod 754 $VBPATH/vboxvmscfg.sh

sudo cp -f \
  _org.virtualbox.vboxautostart.plist \
  /Library/LaunchDaemons/org.virtualbox.vboxautostart.plist
sudo sed -i '' "s/VBOXUSER/$USER/" /Library/LaunchDaemons/org.virtualbox.vboxautostart.plist
sudo sed -i '' "s|VBPATH|$VBPATH|" /Library/LaunchDaemons/org.virtualbox.vboxautostart.plist
sudo chown root:wheel /Library/LaunchDaemons/org.virtualbox.vboxautostart.plist

sudo ln -sfhFv $VBPATH/shutdown.sh /usr/local/bin/shutdown.sh
sudo ln -sfhFv $VBPATH/vbox.sh /usr/local/bin/vbox.sh
sudo ln -sfhFv $VBPATH/vboxvmscfg.sh /usr/local/bin/vboxvmscfg.sh

# sudo
sudo cp -f \
  _sudo_vboxshutdown \
  /etc/sudoers.d/sudo_vboxshutdown
sudo sed -i '' "s/VBOXUSER/$USER/" /etc/sudoers.d/sudo_vboxshutdown
sudo chown root:wheel /etc/sudoers.d/sudo_vboxshutdown
sudo chmod 644 /etc/sudoers.d/sudo_vboxshutdown

# PowerPanel
if [ ! -d /etc/ppupsd ]; then
  sudo mkdir -p /etc/ppupsd
  sudo chown root:wheel /etc/ppupsd
  sudo chmod 755 /etc/ppupsd
fi
sudo cp -f \
  ppmac-shutdown.sh \
  /etc/ppupsd

sudo chown root:wheel /etc/ppupsd/ppmac-shutdown.sh
sudo chmod 755 /etc/ppupsd/ppmac-shutdown.sh

# PowerKey
if [ -d ~/Library/'Application Support'/com.pkamb.PowerKey ]; then
  mkdir -p ~/Library/'Application Support'/com.pkamb.PowerKey
fi
cp -f \
  shutdownPowerKey.sh \
  ~/Library/'Application Support'/com.pkamb.PowerKey
chmod 755 ~/Library/'Application Support'/com.pkamb.PowerKey/shutdownPowerKey.sh

# LockScreen
cp -f \
  _lockscreen.sh \
  $VBPATH/lockscreen.sh
chmod 754 $VBPATH/lockscreen.sh
cp -f \
  _org.virtualbox.lockscreen.plist \
  ~/Library/LaunchAgents/org.virtualbox.lockscreen.plist
sed -i '' "s|VBPATH|$VBPATH|" ~/Library/LaunchAgents/org.virtualbox.lockscreen.plist
sudo chmod 644 ~/Library/LaunchAgents/org.virtualbox.lockscreen.plist
sudo chown $USER:staff ~/Library/LaunchAgents/org.virtualbox.lockscreen.plist

sudo launchctl load /Library/LaunchDaemons/org.virtualbox.vboxautostart.plist

launchctl load ~/Library/LaunchAgents/org.virtualbox.lockscreen.plist

#===============================================================================
# End
#===============================================================================
