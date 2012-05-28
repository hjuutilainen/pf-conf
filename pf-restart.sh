#!/bin/bash

# ==============================================================================
#   pf-restart.sh
#
#   Restart pf firewall and display rules
#   Copyright 2012 Hannes Juutilainen <hjuutilainen@mac.com>
#   https://github.com/hjuutilainen/pf-conf
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# ==============================================================================

# Change to match the actual item (if needed):
LAUNCHD_ITEM_NAME="com.github.hjuutilainen.pf"

LAUNCHCTL="/bin/launchctl"
PFCTL="/sbin/pfctl"
PF_LAUNCHD_ITEM="/Library/LaunchDaemons/$LAUNCHD_ITEM_NAME.plist"

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 2>&1
    exit 1

else
    if [[ -f "$PF_LAUNCHD_ITEM" ]]; then
        
        # Unload the launchd item if already loaded
        $LAUNCHCTL list $LAUNCHD_ITEM_NAME
        if [[ $? -eq 0 ]]; then
            echo ""
            echo "# Unloading $PF_LAUNCHD_ITEM"
            $LAUNCHCTL unload "$PF_LAUNCHD_ITEM"
        fi

        # Load the launchd item
        echo "# Loading $PF_LAUNCHD_ITEM"
        $LAUNCHCTL load -w $PF_LAUNCHD_ITEM

        # Reset the counters
        # echo "# Flushing filter parameters"
        # $PFCTL -F all
        # echo ""
        
        # Show current rules
        sleep 1
        echo "# Current active rules:"
        $PFCTL -a "*" -sr
        echo ""
        
    else
        echo "$PF_LAUNCHD_ITEM not found" 2>&1
        exit 1
    fi
fi
