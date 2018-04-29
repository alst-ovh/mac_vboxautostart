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
# Wrapper for VBoxmanage to setup the VMs.
#===============================================================================

. VBPATH/vboxsettings

VBOXVMSCONFIG="$VBOXVMSCONFIGPATH/vboxvms.conf"
VBOXVMSCONFIG_STARTSTOP="$VBOXVMSCONFIGPATH/vboxvms-start-stop.conf"

#-------------------------------------------------------------------------------
# Activate Config
#-------------------------------------------------------------------------------
activate_config()
{
  vm_start_order=''
  vm_stop_order=''
  echo "==> Begin Config"
  idx='1'
  while [ "$idx" -le "$VM_N" ]
  do
    eval vm_name='$VM_'$idx'_NAME'
    if [[ `echo $vm_name | grep '^[^\!]' | wc -l` -eq 1 ]]
    then
      eval vm_autostart_enabled='$VM_'$idx'_AUTOSTART_ENABLED'
      eval vm_autostart_delay='$VM_'$idx'_AUTOSTART_DELAY'
      eval vm_vrde='$VM_'$idx'_VRDE'
      eval vm_vrde_port='$VM_'$idx'_VRDE_PORT'
      if [ "$vm_autostart_enabled" != "on" ]; then
        vm_autostart_enabled='off'
      fi
      if [ -z "$vm_autostart_delay" ]; then
        vm_autostart_delay='0'
      fi
      if [ "$vm_vrde" != "on" ]; then
        vm_vrde='off'
      fi
      if [ -z "$vm_vrde_port" ]; then
        vm_vrde_port='0'
      fi
      if [ "$vm_autostart_enabled" == "on" ]; then
        if [ -z "$vm_start_order" ]; then
          vm_start_order="$vm_name"
        else
          vm_start_order="$vm_start_order $vm_name"
        fi
        if [ -z "$vm_start_order" ]; then
          vm_stop_order="$vm_name"
        else
          vm_stop_order="$vm_name $vm_stop_order"
        fi
      fi
      echo " ==> Activate $vm_name Configuration ..."
      $VBOXMANAGE modifyvm "$vm_name" --autostart-enabled $vm_autostart_enabled --autostart-delay $vm_autostart_delay --vrde $vm_vrde --vrdeport $vm_vrde_port
    else
      echo " ===> !!! VM_${idx}_NAME $(echo $vm_name | sed -e 's/^!//') is Disabled !!!"
    fi
    idx=`/bin/expr $idx + 1`
  done
  echo
  echo "Autostart Start Order"
  echo "  $vm_start_order"
  echo "Autostart Stop Order"
  echo "  $vm_stop_order"
  echo
  echo "==> End Config"
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
    echo "VM_STARTORDER=""'$vm_start_order'"
    echo
    echo "VM_STOPORDER=""'$vm_stop_order'"
    echo
    echo "#------------------------------------------------------------------------------"
    echo "# End of file"
  ) > $VBOXVMSCONFIG_STARTSTOP
}

if [ -f $VBOXVMSCONFIG ]; then
  . $VBOXVMSCONFIG
else
  echo " ==> $VBOXVMSCONFIG not found, exit ..."
  exit
fi

activate_config

#===============================================================================
# End
#===============================================================================
