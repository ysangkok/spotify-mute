#!/bin/bash -x
while true
	do ./spotifymute_helper.sh
	if [[ 1 -eq $? || 2 -eq $? ]]
		then sleep 2
	fi
done
