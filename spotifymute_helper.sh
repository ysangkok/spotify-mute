#!/bin/bash
#
# THIS IS A COMPILATION OF THE IDEAS OF NUMEROUS PEOPLE
# set commercial mute, so we do not neet to listen to them
# initial source: https://gist.github.com/pcworld/3198763#gistcomment-1265863

is_sink_input_corked(){
    return $(LC_ALL=C pactl list sink-inputs | awk -F: '$0 ~ /Sink Input/ { idx = substr($0, 13) } idx == '"$1"' && $1 ~ /Corked/ {print $2 ~ /yes/; exit}')
}

get_pactl_nr(){
    LC_ALL=C pactl list sink-inputs | awk -v binary="spotify" '
            $0 ~ /Sink Input/ { idx = substr($0, 13); FS = ":" }
            $1 ~ /Properties/ { FS = " " }
            $1 == "application.process.binary" && $3 == "\"" binary "\"" {print idx; exit}
        '
    #LC_ALL=C pacmd list-sink-inputs | awk -v binary="spotify" '
    #        $1 == "index:" {idx = $2}
    #        $1 == "application.process.binary" && $3 == "\"" binary "\"" {print idx; exit}
    #    '

    # awk script by Glenn Jackmann (http://askubuntu.com/users/10127/)
    # first posted on http://askubuntu.com/a/180661
}

mute(){
    for PACTLNR in $(get_pactl_nr); do
        if is_sink_input_corked $PACTLNR; then # returns 0 when not-corked, bash things unequal 0 false, try `if $(exit 3); then echo trudat; else echo noway; fi`
             pactl set-sink-input-mute "$PACTLNR" "$@"
        else
            if [[ $1 == "yes" ]]; then
                echo "Sink input corked, unmuting"
                pactl set-sink-input-mute "$PACTLNR" no
                (sleep 1; mute $1)&
            fi
        fi
    done
}

netw_prepare(){
    NETW=0
    if [ ! -z ${PULSE_SERVER+x} ]; then
        NETW=1
        PASSWD_FILE=$(mktemp)
        chmod go-rwx "$PASSWD_FILE"
        #read -s $SSHPASS
        echo "Enter password for ssh (will echo)"
        cat > "$PASSWD_FILE"
        trap "rm -f $PASSWD_FILE" INT
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
        exit 1
    fi

    trap "exit" USR1
    trap "mute_div no; kill -USR1 0" INT

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
    set -o nounset
    set -o pipefail
    set -e
    main "$@"
fi
