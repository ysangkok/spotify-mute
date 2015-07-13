#!/bin/bash
#
#THIS IS A COMPILATION OF THE IDEAS OF NUMEROUS PEOPLE
#works for version 1.0.9 of spotify

# set commercial mute, so we do not neet to listen to them

when-changed ~/bin/spotify_blacklist.txt -c "kill $$" &

xprop -spy -id $(wmctrl -lx | awk -F' ' '$3 == "spotify.Spotify" {print $1}') _NET_WM_NAME |
while read -r XPROPOUTPUT; do
        XPROP_TRACKDATA="$(echo "$XPROPOUTPUT" | cut -d \" -f 2 )"

        # show something
        echo "Checking against: $XPROP_TRACKDATA"

        amixer -D pulse set Master unmute >> /dev/null
	while read -r LINE; do
            echo Checking $LINE
            if grep -Fq "$LINE" <(echo "$XPROP_TRACKDATA"); then
                echo "commercial: yes"
                amixer -D pulse set Master mute >> /dev/null
		break
            fi
	done < ~/bin/spotify_blacklist.txt
done
