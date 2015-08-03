#!/bin/bash
#
# THIS IS A COMPILATION OF THE IDEAS OF NUMEROUS PEOPLE
# set commercial mute, so we do not neet to listen to them
# initial source: https://gist.github.com/pcworld/3198763#gistcomment-1265863

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
      pactl set-sink-input-mute "$PACTLNR" "$@"
    done
}

netw_prepare(){
    NETW=0
    if [[ $PULSE_SERVER != "" ]]; then
        NETW=1
        PASSWD_FILE=$(mktemp)
        chmod go-rwx "$PASSWD_FILE"
        #read -s $SSHPASS
        echo "Enter password for ssh (will echo)"
        cat > "$PASSWD_FILE"
    fi
}

mute_div(){
    echo Muting... "$@"
    if [ $NETW -eq 1 ]; then
        if [[ "$@" == yes ]]; then
            sshpass -f "$PASSWD_FILE" ssh "$PULSE_SERVER" "amixer -D pulse set Master mute"
        else
            #echo "amixer -D pulse set Master unmute" > $PIP
            sshpass -f "$PASSWD_FILE" ssh "$PULSE_SERVER" "amixer -D pulse set Master unmute"
        fi
    else
        mute "$@"
    fi
}


main(){
    DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

    netw_prepare

    ID=$(wmctrl -lx | awk -F' ' '$3 == "spotify.Spotify" {print $1}')

    if [[ $ID == "" ]]; then
            mute_div no
            exit 1;
    fi

    trap "exit" USR1
    trap "rm -f $PASSWD_FILE; mute_div no; kill -USR1 0" INT

    $DIR/when-changed "${BASH_SOURCE[0]}" "$DIR/blacklist.txt" -c "kill -USR1 $$ 2>&1" &

    while read -r XPROPOUTPUT; do
            XPROP_TRACKDATA="$(echo "$XPROPOUTPUT" | cut -d \" -f 2 )"

            # show something
            echo "Checking against: $XPROP_TRACKDATA"

            #amixer -D pulse set Master unmute
            NOT_IN=1
            while read -r LINE; do
                #echo Checking $LINE
                if grep -Fq "$LINE" <(echo "$XPROP_TRACKDATA"); then
                    NOT_IN=0
                    #amixer -D pulse set Master mute
                    mute_div yes
                    break
                fi
            done < "$DIR/blacklist.txt"
            if [ $NOT_IN -eq 1 ]; then
                mute_div no
            fi
    done < <(xprop -spy -id "$ID" _NET_WM_NAME)
}

if [[ ${BASH_SOURCE[0]} = $0 ]]; then
    main "$@"
fi
