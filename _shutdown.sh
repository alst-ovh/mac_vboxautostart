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

if [[ "$@" = *"-sound"* ]]; then
  PLAYSOUND=true
else
  PLAYSOUND=false
fi
PARAMS=$(echo $@ | sed -e "s/\-sound//")

if [ ! -z "$PARAMS" ];then
  if [ "$PLAYSOUND" = true ]; then
    /usr/bin/afplay "VBPATH/shutdown.aiff"
    shift;
  fi
  sudo /usr/local/bin/vbox.sh stopall
  sudo /sbin/shutdown $@
else
  echo "usage: shutdown [-sound] [-] [-h [-u] [-n] | -r [-n] | -s | -k] time [warning-message ...]"
  exit 1
fi

#===============================================================================
# End
#===============================================================================
