#!/bin/bash
#############################################################################
# Author      : TimVNL                                                      #
# GitHub      : https://github.com/TimVNL/usg-kpn-ftth/                     #
# Version     : 0.1                                                         #
#---------------------------------------------------------------------------#
# Description :                                                             #
#                                                                           #
# This file does the following things:                                      #
#   1. Check if igmpproxy is running, if not, execute restart igmp-proxy.   #
#---------------------------------------------------------------------------#
# Installation :                                                            #
#                                                                           #
# Place this file at /config/igmpchecker.sh and make it                     #
# executable (chmod +x /config/igmpchecker.sh).                             #
#############################################################################

logFile="/var/log/igmpproxy-restart.log"

# Check if log exists if nog create
if [ ! -f $logFile ]; then
  touch $logFile
  echo "[$(date)] [igmpchecker.sh] Created logFile" >> ${logFile}
fi

# Check if igmp proxy is running and restart if not.
if ! pidof igmpproxy >/dev/null 2>&1; then
  echo "[$(date)] [igmpchecker.sh] IGMP Proxy not running" >> ${logFile}
  # Restarting igmp proxy
  echo "[$(date)] [igmpchecker.sh] Restarting IGMP proxy" >> ${logFile}
  /bin/vbash -ic 'restart igmp-proxy'
fi
