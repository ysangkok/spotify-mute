#!/bin/bash -x
#
#THIS IS A COMPILATION OF THE IDEAS OF NUMEROUS PEOPLE
#works for version 1.0.9 of spotify

# set commercial mute, so we do not neet to listen to them

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
        #PIP=$(mktemp -u)
        #mkfifo "$PIP"
        PSWDF=$(mktemp)
        cat > $PSWDF
        #REMOTE=$(sshpass -f $PSWDF ssh "$PULSE_SERVER" "mktemp")
        #rsync --rsh="sshpass -f $PSWDF ssh $PULSE_SERVER" "$0" $REMOTE
        #cat $PIP | sshpass -f $PSWDF ssh "$PULSE_SERVER" "chmod +x $REMOTE; $REMOTE" &
	#echo DONE CATTING SCRIPT
    fi
}

mute_div(){
    if [ $NETW -eq 1 ]; then
        #echo "mute '$@'" > "$PIP"
        if [[ "$@" == yes ]]; then
            sshpass -f $PSWDF ssh "$PULSE_SERVER" "amixer -D pulse set Master mute"
        else
            #echo "amixer -D pulse set Master unmute" > $PIP
            sshpass -f $PSWDF ssh "$PULSE_SERVER" "amixer -D pulse set Master unmute"
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

    trap "mute_div no && trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

    when-changed "${BASH_SOURCE[0]}" "$DIR/blacklist.txt" -c "kill $$" &

    while read -r XPROPOUTPUT; do
            XPROP_TRACKDATA="$(echo "$XPROPOUTPUT" | cut -d \" -f 2 )"

            # show something
            # echo "Checking against: $XPROP_TRACKDATA"

            #amixer -D pulse set Master unmute
            mute_div no
            while read -r LINE; do
                #echo Checking $LINE
                if grep -Fq "$LINE" <(echo "$XPROP_TRACKDATA"); then
                    #amixer -D pulse set Master mute
                    mute_div yes
                    break
                fi
            done < "$DIR/blacklist.txt"
    done < <(xprop -spy -id "$ID" _NET_WM_NAME)
}

if [[ ${BASH_SOURCE[0]} = $0 ]]; then
    main "$@"
fi
