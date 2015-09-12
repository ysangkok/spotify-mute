# spotify-blacklist-mute
*for muting ads*

**NOTE: THIS PROJECT IS DORMANT**. This project is based on blacklisting. When Spotify has DBUS support (versions 1.0.0-1.0.11 did not), blacklisting isn't needed, and you can use blockify. If blockify breaks for you, let me know, and I'll fix this script.

Tested with version 1.0.9 and 1.0.11 (Linux). May work on BSD too.

Only mutes the Spotify sink when running locally. If `PULSE_SERVER` is defined, it will mute all audio on the remote machine using SSH (will ask for password and save it. Pretty unsafe but it is meant for usage on machines you trust).

The startup script (`spotifymute`) launches GNU Screen, so if everything works according to plan, you can detach using e.g. `<Control-A> <Control-D>`.

You need to do `git submodule init`, `git submodule update`, because we rely on `when-changed` to detect live edits to the `blacklist.txt` and reevaluate the muting decision.

Todo
----

* Use https://bitbucket.org/SpartanJ/efsw to support FreeBSD also.
