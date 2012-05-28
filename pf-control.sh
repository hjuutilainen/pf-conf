#!/bin/bash

# ==============================================================================
#   pf-control.sh
# 
#   Packet Filter control script
#   Copyright 2012 Hannes Juutilainen <hjuutilainen@mac.com>
#   https://github.com/hjuutilainen/pf-conf
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# ==============================================================================

# ========================================
# Declare variables
# ========================================
DEFAULT_RULES_FILE="/etc/pf.anchors/com.github.hjuutilainen.pf.rules"
MACROS_FILE="/etc/pf.anchors/com.github.hjuutilainen.pf.macros"
CUSTOM_RULES_FILE="/etc/pf.anchors/com.github.hjuutilainen.pf.custom"
CONF_DIR_CUSTOM="/etc/pf.anchors/com.github.hjuutilainen.pf.d"
PFCTL="/sbin/pfctl"
ECHO="/bin/echo"
STAT="/usr/bin/stat"
PRINTF="/usr/bin/printf"
SYSCTL="/usr/sbin/sysctl"
OP_MODE="restart"

# ========================================
function usage () {
# ========================================
    echo ""
    echo "$0 [-h|--help|h] [start|stop|restart]"
    echo ""
    echo "Where:"
    echo "-h|--help|h   Print this message"
    echo "start         Start the firewall (without flushing)"
    echo "stop          Stop the firewall and flush rules"
    echo "restart       Flush and re-read all rules and restart firewall"
    exit
}

# ========================================
function checkFilePerms () {
# ========================================
    FILESTATS=`$STAT -f "%Su:%Sg, %SHp%SMp%SLp" "$1"`
    if [[ $FILESTATS != "root:wheel, rw-r--r--" ]]; then
    return 1
    else
    return 0
    fi
}

# ========================================
function checkDirectoryPerms () {
# ========================================
    FILESTATS=`$STAT -f "%Su:%Sg, %SHp%SMp%SLp" "$1"`
    if [[ $FILESTATS != "root:wheel, rwxr-xr-x" ]]; then
    return 1
    else
    return 0
    fi
}

# ========================================
function verifyFiles () {
# ========================================
    $ECHO ""
    $ECHO "Verifying configuration security:"
    
    FORMAT="%-50s%-10s\n"
    INSECURE="Failed (Insecure, will not be loaded)"
    VERIFIED="OK"
    NOT_FOUND="Failed (No such file or directory)"
    OBJECT=""
    RESULT=""
    
    OBJECT=$CONF_DIR_CUSTOM
    if [[ -d "$CONF_DIR_CUSTOM" ]]; then
    if checkDirectoryPerms "$CONF_DIR_CUSTOM"; then
        RESULT=$VERIFIED
    fi
    else
    RESULT=$NOT_FOUND
    fi
    $PRINTF "$FORMAT" "$OBJECT" "$RESULT"

    OBJECT=$CUSTOM_RULES_FILE
    if [[ -f "$CUSTOM_RULES_FILE" ]]; then
    if checkFilePerms "$CUSTOM_RULES_FILE"; then
        RESULT=$VERIFIED
    else
        RESULT=$INSECURE
    fi
    else
    RESULT=$NOT_FOUND
    fi
    $PRINTF "$FORMAT" "$OBJECT" "$RESULT"
    
    if [[ -d $CONF_DIR_CUSTOM ]]; then
    shopt -s nullglob
    DID_FIND_CUSTOMRULE_FILES=0
    CUSTOM_RULES=/etc/pf.anchors/com.github.hjuutilainen.custom.d/*
    for f in $CUSTOM_RULES
    do
        OBJECT=$f
        if checkFilePerms "$f"; then
        RESULT=$VERIFIED
        DID_FIND_CUSTOMRULE_FILES=1
        else
        RESULT=$INSECURE
        fi
        $PRINTF "$FORMAT" "$OBJECT" "$RESULT"
    done
    shopt -u nullglob
    fi
}

# ========================================
function enablePfctl () {
# ========================================
    $ECHO ""
    $ECHO "Starting Packet Filter and reading default rules"
    $PFCTL -E > /dev/null 2>&1
    $PFCTL -f /etc/com.github.hjuutilainen.pf.conf > /dev/null 2>&1
}

# ========================================
function disablePfctl () {
# ========================================
    $ECHO ""
    $ECHO "Disabling Packet Filter"
    $PFCTL -d
}

# ========================================
function loadCustomRules () {
# ========================================
    FILES_TO_LOAD=( "$MACROS_FILE" )
    
    # Add custom rule file
    if [[ -f "$CUSTOM_RULES_FILE" ]]; then
    $ECHO ""
    $ECHO "Loading $CUSTOM_RULES_FILE:"
    if checkFilePerms "$CUSTOM_RULES_FILE"; then
        $ECHO "---> $CUSTOM_RULES_FILE"
        FILES_TO_LOAD=( "${FILES_TO_LOAD[@]}" "$CUSTOM_RULES_FILE" )
    fi
    fi
    
    # Add each file in custom rule directory
    $ECHO ""
    $ECHO "Loading rule files in /etc/pf.anchors/com.github.hjuutilainen.pf.d/"
    shopt -s nullglob
    DID_FIND_CUSTOMRULE_FILES=0
    CUSTOM_RULES=$CONF_DIR_CUSTOM/*
    for f in $CUSTOM_RULES
    do
    if checkFilePerms "$f"; then
        $ECHO "---> $f"
        FILES_TO_LOAD=( "${FILES_TO_LOAD[@]}" "$f" )
        DID_FIND_CUSTOMRULE_FILES=1
    fi
    done
    shopt -u nullglob
    [ $DID_FIND_CUSTOMRULE_FILES -eq 0 ] && $ECHO "---> Directory is empty"
    
    # Read all files that passed permissions check
    # and feed the results to pfctl
    cat ${FILES_TO_LOAD[@]} | $PFCTL -a "com.github.hjuutilainen.pf/custom" -f- > /dev/null 2>&1
}

# ========================================
function showCurrentRules () {
# ========================================
    $ECHO ""
    $ECHO "Current rules:"
    $PFCTL -a '*' -sr
}

# ========================================
function configureKernelParameters () {
# ========================================
    $SYSCTL -w net.inet.ip.fw.enable=1 > /dev/null 2>&1
    $SYSCTL -w net.inet.ip.fw.verbose=2 > /dev/null 2>&1
    $SYSCTL -w net.inet6.ip6.fw.verbose=0 > /dev/null 2>&1
    $SYSCTL -w net.inet.ip.fw.verbose_limit=0 > /dev/null 2>&1
    $SYSCTL -w net.inet.ip.forwarding=0 > /dev/null 2>&1
}


while test -n "$1"; do
  case $1 in 
      -h|--help|h) 
      usage
      ;;
      start) 
      OP_MODE="start"
      shift
      ;;
      stop) 
      OP_MODE="stop"
      shift
      ;;
      restart)
      OP_MODE="restart"
      shift
      ;; 
      *) 
      usage
      ;; 
  esac
done

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 2>&1
    exit 1
else
    verifyFiles
    
    if [[ $OP_MODE == "start" ]]; then
        configureKernelParameters
        enablePfctl
        loadCustomRules
        showCurrentRules
    
    elif [[ $OP_MODE == "stop" ]]; then
        disablePfctl
    
    elif [[ $OP_MODE == "restart" ]]; then
        configureKernelParameters
        disablePfctl
        enablePfctl
        loadCustomRules
        showCurrentRules
    
    else
        echo "Unknown operation mode..."
        usage
        exit 1
    fi
fi

exit 0
