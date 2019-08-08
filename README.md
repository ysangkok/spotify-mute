# spotify-mute
*for muting ads*

Tested with version 1.0.77 (Linux). May work on BSD too.

Only mutes the Spotify sink when running locally. If `PULSE_SERVER` is defined, it will mute all audio on the remote machine using SSH (will ask for password and save it. Pretty unsafe but it is meant for usage on machines you trust).

The startup script (`spotifymute`) launches GNU Screen, so if everything works according to plan, you can detach using e.g. `<Control-A> <Control-D>`.

Todo
----

* Mute PulseAudio sink on remote host instead of all audio

See also
----

* https://github.com/abba23/spotify-adblock-linux which works using LD_PRELOAD and excluding certain URL patterns
