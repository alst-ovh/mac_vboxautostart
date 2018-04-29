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
# Wrapper for VBoxmanage and starts or stops the VMs.
#
#===============================================================================

. VBPATH/vboxsettings

VBOXVMSCONFIG="$VBOXVMSCONFIGPATH/vboxvms.conf"
VBOXVMSCONFIG_STARTSTOP="$VBOXVMSCONFIGPATH/vboxvms-start-stop.conf"

#-------------------------------------------------------------------------------
# Check Config
#-------------------------------------------------------------------------------
check_config()
{
  if [ ! -f $VBOXVMSCONFIG ]; then
    create_config
  fi
  $VBOXEDITOR $VBOXVMSCONFIG
  if ask "Activate VMs Config now ?"; then
    if [ ! -z "$($VBOXMANAGE list runningvms)" ]; then
      echo -e "\a"
      if ask "WARNING: VMs are running, Shutdown now and activate ?"; then
        /usr/local/bin/vbox.sh stopall
        clear
        vboxvmscfg.sh
      else
        echo -e "\a"
        echo " ->WARNING: Config aborted !"
      fi
    else
      clear
      vboxvmscfg.sh
    fi
  fi
}

#-------------------------------------------------------------------------------
# Create Config
#-------------------------------------------------------------------------------
create_config()
{
  write_header()
  {
    (
      echo "#------------------------------------------------------------------------------"
      echo "# Copyright (C) 2018 Albert Steiner"
      echo "# Author: Albert Steiner albert@alst.ovh"
      echo "# 28/01/2018"
      echo "#"
      echo "# This file is free software you can redistribute it and/or modify"
      echo "# it under the terms of the GNU General Public License (GPL)"
      echo "# as published by the Free Software Foundation, in version 2"
      echo "# It is distributed in the  hope that it will be useful,"
      echo "# but WITHOUT ANY WARRANTY of any kind."
      echo "#------------------------------------------------------------------------------"
      echo
      echo "#------------------------------------------------------------------------------"
      echo "# (Prefix a VM_x_NAME with a ! to Disable it)"
      echo "# VM_x = Start Stop Order, Order it here on your needs"
      echo "# VM_x_AUTOSTART_ENABLED = on or off, Enables or Disables Autostart, If Empty Default = off"
      echo "# VM_x_AUTOSTART_DELAY = Delay in Seconds, If Empty Default = 0"
      echo "# VM_x_VRDE = on or off, If Empty Default = off"
      echo "# VM_x_VRDEPORT = Portnumber, If Empty Default = 0"
      echo "#------------------------------------------------------------------------------"
      echo
      echo "VM_N=""'$idx'"
      echo
    ) > $VBOXVMSCONFIG
  }
  write_footer()
  {
    (
      echo "#------------------------------------------------------------------------------"
      echo "# End of file"
    ) >> $VBOXVMSCONFIG
  }
  echo " ==> $VBOXVMSCONFIG not found ..."
  echo "  ==> Create $VBOXVMSCONFIG, please wait ..."
  :>${VBOXVMSCONFIG}1
  idx=0
  for VM in $($VBOXMANAGE list vms | cut -d' ' -f1 | cut -d'"' -f2)
  do
    idx=`expr $idx + 1`
    AUTOSTART_ENABLED=$($VBOXMANAGE showvminfo "$VM" | grep -e ^"Autostart Enabled:" | cut -d: -f2 | cut -d' ' -f2)
    AUTOSTART_DELAY=$($VBOXMANAGE showvminfo "$VM" | grep -e ^"Autostart Delay:" | cut -d: -f2 | cut -d' ' -f2)
    VRDE=$($VBOXMANAGE showvminfo "$VM" | grep -e ^"VRDE:" | cut -d: -f2 | sed -e 's/^[ ]*//' | cut -d' ' -f1)
    VRDE_PORT=$($VBOXMANAGE showvminfo "$VM" | grep -e ^"VRDE property: TCP/Ports" | cut -d= -f2 | sed -e 's/^[ ]*//' | sed -e 's/"//g')
    if [ -z "$AUTOSTART_ENABLED" ]; then
      AUTOSTART_ENABLED='off'
    fi
    if [ -z "$AUTOSTART_DELAY" ]; then
      AUTOSTART_DELAY='0'
    fi
    if [ -z "$VRDE" ] || [ "$VRDE" == "disabled" ] ; then
      VRDE='off'
    fi
    if [ -z "$VRDE" ] || [ "$VRDE" == "enabled" ] ; then
      VRDE='on'
    fi
    if [ -z "$VRDE_PORT" ]; then
      VRDE_PORT='0'
    fi
    (
      echo "VM_"$idx"_NAME=""'$VM'"
      echo "VM_"$idx"_AUTOSTART_ENABLED=""'$AUTOSTART_ENABLED'"
      echo "VM_"$idx"_AUTOSTART_DELAY=""'$AUTOSTART_DELAY'"
      echo "VM_"$idx"_VRDE=""'$VRDE'"
      echo "VM_"$idx"_VRDE_PORT=""'$VRDE_PORT'"
      echo
    )  >> ${VBOXVMSCONFIG}1
  done
  write_header
  cat ${VBOXVMSCONFIG}1 >> $VBOXVMSCONFIG
  rm ${VBOXVMSCONFIG}1
  write_footer
}

#-------------------------------------------------------------------------------
# Stop All
#-------------------------------------------------------------------------------

function stopall()
# Stop all running VMs
{
  stop_vm()
  {
    echo " Shutting $1 Down with $2 ..."
    $VBOXMANAGE controlvm "$1" "$2"
  }
  stop_all()
  {
    echo " VMs Running, Shutting Down with $1 ..."
    for VM in $($VBOXMANAGE list runningvms | cut -d' ' -f1 | cut -d'"' -f2)
    do
      echo "  -> Shutting down $VM with $1"
      $VBOXMANAGE controlvm "$VM" "$1"
    done
  }
  echo "-->" `date` "$USER Begin Stop all running VMs"
  if [ ! -z "$($VBOXMANAGE list runningvms)" ]; then
    # Stop Autostart Enabled Ordered
    echo "--> Begin Stop VMs Ordered"
    for VM in $VM_STOPORDER
    do
      vm_running=$($VBOXMANAGE list runningvms | grep -e "$VM")
      if [ ! -z "$vm_running" ]; then
        stop_vm $VM acpipowerbutton
      fi
    done
    sleep $VBOXSLEEP
    VBOXWAIT=$((VBOXWAIT + $VBOXSLEEP))
    # Stop all Other
    echo "--> Begin Stop Others"
    while [ ! -z "$($VBOXMANAGE list runningvms)" ]
    do
      stop_all acpipowerbutton
      sleep $VBOXSLEEP
      VBOXWAIT=$((VBOXWAIT + $VBOXSLEEP))
      if [[ "$VBOXWAIT" -ge $VBOXMAXWAIT ]]; then
        stop_all savestate
      fi
    done
  else
    echo " No VMs Running, Nothing to do ..."
  fi
  echo "-->" `date` "$USER End Stop all running VMs"
  exit 0
}

#-------------------------------------------------------------------------------
# Start All
#-------------------------------------------------------------------------------

function startall()
{
  start_vm()
  {
    AUTOSTART=$($VBOXMANAGE showvminfo "$1" | grep -e ^"Autostart Enabled:" | cut -d: -f2 | cut -d' ' -f2)
    ACCELERATION3D=$($VBOXMANAGE showvminfo "$1" | grep -e ^"3D Acceleration:" | cut -d: -f2 | cut -d' ' -f2)
    AUTOSTARTDELAY=$($VBOXMANAGE showvminfo "$1" | grep -e ^"Autostart Delay:" | cut -d: -f2 | cut -d' ' -f2)
    VM_DIR=$($VBOXMANAGE showvminfo "$1" | grep -e ^"Config file:" | cut -d: -f2 | sed -e 's/^[ ]*//' | xargs dirname)
    echo " -> Autostart Enabled: = $AUTOSTART in VM $1"
    if [ "$ACCELERATION3D" = "on" ]; then
      echo " -> WARNING: 3D Acceleration <on> wan't start on boot with launchd !!!"
    fi
    if [ -d "$VM_DIR" ]; then
      if [ "$AUTOSTART" = "on" ]; then
        if [ ! -z $AUTOSTARTDELAY ]; then
          echo "  -> Delay Starting $1 $AUTOSTARTDELAY seconds..."
          sleep $AUTOSTARTDELAY
        fi
        echo "  -> Starting $1"
        $VBOXMANAGE startvm "$1" --type headless
      else
        echo "  -> Not Starting $1"
      fi
    else
      echo "  -> Directory $VM_DIR not found, Not Starting $1"
    fi
  }
  # Start all VMs with --autostart on
  echo "-->" `date` "$USER Begin Start VMs"
  vm_list=''
  for VM in $($VBOXMANAGE list vms | cut -d' ' -f1 | cut -d'"' -f2); do
    if [ -z "$vm_list" ]; then
      vm_list="$VM"
    else
      vm_list="$vm_list $VM"
    fi
  done
  if [ ! -z "$VM_STARTORDER" ];then
    for VM in $VM_STARTORDER; do
      vm_list=`echo $vm_list | sed "s/ $VM//"`
    done
  fi
  # Start Autostart Enabled Ordered
  echo "--> Begin Start VMs Ordered"
  for VM in $VM_STARTORDER
  do
    start_vm $VM
  done
  # Try the Rest
  echo "--> Begin Try Start Others"
  for VM in $vm_list
  do
    start_vm $VM
  done
  echo "-->" `date` "End Start VMs"
  exit 0
}

if [ -f "$VBOXMANAGE" ]; then

  if [ -f $VBOXVMSCONFIG_STARTSTOP ]; then
    . $VBOXVMSCONFIG_STARTSTOP
    echo "Start Order: $VM_STARTORDER"
    echo "Stop Order: $VM_STOPORDER"
    echo
  fi

  case "${1}" in
    startall)
      startall
      ;;
    stopall)
      stopall
      ;;
    cfg)
      check_config
      ;;
    *)
      echo "usage: startall|stopall|cfg"
      exit 1
  esac
else
  echo "ERROR: VirtualBox.app not found, Install Virtualbox first, abort ..."
  exit 1
fi

#===============================================================================
# End
#===============================================================================
