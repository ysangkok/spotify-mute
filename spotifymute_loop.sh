#!/bin/bash -x
while true
	do ./spotifymute_helper.sh
	RET=$?
	if [[ 1 -eq $RET ]]
		then sleep 2
	fi
done
