#!/bin/bash -x
while true
	do ./spotifymute_helper.sh
	RET=$?
	if [[ 1 -eq $RET ]]
		then break
	fi
done
read SCRIPT_DONE
