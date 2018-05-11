#!/bin/bash

/bin/sleep 5
/usr/bin/osascript <<EOD
        tell application "System Events"
                key code 12 using {control down, command down}
        end tell
EOD
