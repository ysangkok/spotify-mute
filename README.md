# spotify-blacklist-mute
*for muting ads*

Note that the name has become a misnomer, since automatic ad-detection over DBUS is working again now. The blacklist is still used, but no longer needs to be updated.

Tested with version 1.0.43 (Linux). May work on BSD too.

Only mutes the Spotify sink when running locally. If `PULSE_SERVER` is defined, it will mute all audio on the remote machine using SSH (will ask for password and save it. Pretty unsafe but it is meant for usage on machines you trust).

The startup script (`spotifymute`) launches GNU Screen, so if everything works according to plan, you can detach using e.g. `<Control-A> <Control-D>`.

You need to do `git submodule init`, `git submodule update`, because we rely on `when-changed` to detect live edits to the `blacklist.txt` and reevaluate the muting decision.

Todo
----

* Mute PulseAudio sink on remote host instead of all audio
