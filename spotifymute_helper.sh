#!/bin/bash -x
#
#THIS IS A COMPILATION OF THE IDEAS OF NUMEROUS PEOPLE
#works for version 1.0.9 of spotify

# set commercial mute, so we do not neet to listen to them

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

get_pactl_nr(){
    LC_ALL=C pacmd list-sink-inputs | awk -v binary="spotify" '
            $1 == "index:" {idx = $2}
            $1 == "application.process.binary" && $3 == "\"" binary "\"" {print idx; exit}
        '
    # awk script by Glenn Jackmann (http://askubuntu.com/users/10127/)
    # first posted on http://askubuntu.com/a/180661
}

mute(){
    for PACTLNR in $(get_pactl_nr); do
      pactl set-sink-input-mute "$PACTLNR" yes
    done
}

unmute(){
    for PACTLNR in $(get_pactl_nr); do
        pactl set-sink-input-mute "$PACTLNR" no
    done
}

ID=$(wmctrl -lx | awk -F' ' '$3 == "spotify.Spotify" {print $1}')

if [[ $ID == "" ]]; then
        unmute
        exit 1;
fi

trap "echo Dying!; exit" TERM

when-changed "${BASH_SOURCE[0]}" "$DIR/blacklist.txt" -c "kill $$" &

while read -r XPROPOUTPUT; do
        XPROP_TRACKDATA="$(echo "$XPROPOUTPUT" | cut -d \" -f 2 )"

        # show something
        # echo "Checking against: $XPROP_TRACKDATA"

        #amixer -D pulse set Master unmute
        unmute
        while read -r LINE; do
            #echo Checking $LINE
            if grep -Fq "$LINE" <(echo "$XPROP_TRACKDATA"); then
                #amixer -D pulse set Master mute
                mute
                break
            fi
        done < "$DIR/blacklist.txt"
done < <(xprop -spy -id "$ID" _NET_WM_NAME)
