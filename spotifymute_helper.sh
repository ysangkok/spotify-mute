#!/bin/bash
#
#THIS IS A COMPILATION OF THE IDEAS OF NUMEROUS PEOPLE
#works for the current version of spotify

# set commercial mute, so we do not neet to listen to them

echo "----------------------------------------------------------"
echo ""
echo "   Mute spotify commercial"
echo ""
echo "----------------------------------------------------------"

when-changed ~/bin/spotify_blacklist.txt -c "kill $$" &

xprop -spy -id $(wmctrl -lx | awk -F' ' '$3 == "spotify.Spotify" {print $1}') WM_NAME |
while read -r XPROPOUTPUT; do
        XPROP_TRACKDATA="$(echo "$XPROPOUTPUT" | cut -d \" -f 2 )"

        # show something
        echo "XPROP:      $XPROP_TRACKDATA"

        if grep -Fxq "$XPROP_TRACKDATA" ~/bin/spotify_blacklist.txt
        then
            echo "commercial: yes"
            amixer -D pulse set Master mute >> /dev/null
        else
            echo "commercial: no"
            amixer -D pulse set Master unmute >> /dev/null
        fi
        echo "----------------------------------------------------------"
done
