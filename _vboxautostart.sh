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
#
# Based on the VBoxAutostartDarwin.sh part of VirtualBox Open Source Edition (OSE)
# Copyright (C) 2012-2017 Oracle Corporation
#
# Based on https://github.com/freedev/macosx-script-boot-shutdown
# from Vincenzo D'Amore v.damore@gmail.com
#
# The per user autostart daemon works not for me, by the way i use VBoxmanage.
# Wrapper for VBoxmanage and starts or stops the VMs via launchd.
#===============================================================================

. VBPATH/vboxsettings

function checklogfilepath()
{
  if [ ! -d ${LOGFILEPATH} ]; then
    mkdir ${LOGFILEPATH}
  fi
}

#-------------------------------------------------------------------------------
# Rotate Log
#-------------------------------------------------------------------------------

function rotatelogfile()
{
  if [ -f ${LOGFILEPATH}/vboxautostart.log ]; then
    for (( i = 10; i > 0; i-- ))
    do
      if [ $i -gt 1 ]; then
        let "ii = $i -1"
        if [ -f ${LOGFILEPATH}/vboxautostart.log.10 ]; then
          rm ${LOGFILEPATH}/vboxautostart.log.10
        fi
        if [ -f ${LOGFILEPATH}/vboxautostart.log.$ii ]; then
          cp -af ${LOGFILEPATH}/vboxautostart.log.$ii ${LOGFILEPATH}/vboxautostart.log.$i
        fi
      else
        if [ -f ${LOGFILEPATH}/vboxautostart.log ]; then
          cp -af ${LOGFILEPATH}/vboxautostart.log ${LOGFILEPATH}/vboxautostart.log.1
        fi
      fi
    done
  fi
}

#-------------------------------------------------------------------------------
# Check Kernelmodules
#-------------------------------------------------------------------------------

function waitForKernelModules()
{
  VBOX_EXT=0
  CHECK_CNT=0
  until [[ $VBOX_EXT -eq 1 || $CHECK_CNT -gt 60 ]]; do
    echo Check for VBox-Kernelmodules - ${CHECK_CNT}
    sleep 1
    VBOX_EXT=1
    CHECK_CNT=$(( ${CHECK_CNT} + 1 ))
    if kextstat -lb org.virtualbox.kext.VBoxDrv 2>&1 | grep -q org.virtualbox.kext.VBoxDrv; then
      echo "Found org.virtualbox.kext.VBoxDrv. Good."
    else
      VBOX_EXT=0
    fi
    if kextstat -lb org.virtualbox.kext.VBoxUSB 2>&1 | grep -q org.virtualbox.kext.VBoxUSB; then
      echo "Found org.virtualbox.kext.VBoxUSB. Good."
    else
      VBOX_EXT=0
    fi
    if kextstat -lb org.virtualbox.kext.VBoxNetFlt 2>&1 | grep -q org.virtualbox.kext.VBoxNetFlt; then
      echo "Found org.virtualbox.kext.VBoxNetFLT. Good."
    else
      VBOX_EXT=0
    fi
    if kextstat -lb org.virtualbox.kext.VBoxNetAdp 2>&1 | grep -q org.virtualbox.kext.VBoxNetAdp; then
      echo "Found org.virtualbox.kext.VBoxAdp. Good."
    else
      VBOX_EXT=0
    fi
  done
}

#-------------------------------------------------------------------------------
# Stop All
#-------------------------------------------------------------------------------

function shutdown()
# Stop all running VMs
{
  checklogfilepath
  echo
  echo "-->" `date` "$USER Begin Shutdown..."
  #Use pkill VirtualBox on Shutdown to prevent the destroy of .vbox Files
  /usr/bin/pkill VirtualBox
  /usr/local/bin/vbox.sh stopall
  echo "-->" `date` "$USER End Shutdown"
  rotatelogfile
  exit 0
}

#-------------------------------------------------------------------------------
# Start All
#-------------------------------------------------------------------------------

function startup()
{
  # Start all VMs with --autostart on
  checklogfilepath
  echo "" > ${LOGFILEPATH}/vboxautostart.log
  echo "-->" `date` "$USER Begin Startup..."
  waitForKernelModules
  /usr/local/bin/vbox.sh startall
  echo "-->" `date` "$USER End Startup"
  tail -f /dev/null &
  wait $!
}

if [ -f "$VBOXMANAGE" ]; then
  trap shutdown SIGTERM
  trap shutdown SIGKILL
  startup;
else
  echo "ERROR: VirtualBox.app not found, abort ..."
  exit 1
fi

#===============================================================================
# End
#===============================================================================
