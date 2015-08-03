# spotify-blacklist-mute
*for muting ads*

Tested with version 1.0.9 and 1.0.11 (Linux). May work on BSD too.

Only mutes the Spotify sink when running locally. If `PULSE_SERVER` is defined, it will mute all audio on the remote machine using SSH (will ask for password and save it. Pretty unsafe but it is meant for usage on machines you trust).
