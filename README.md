# mldonkey docker image

This repository host a docker compose file for building mldonkey server.

## Usage

Modifiy `env` file to match your preferences, then
```
$ ./rebuild.sh
```

## Credits

Based on carlonluca/mldonkey docker image and carlonluca/docker-mldonkey compose file.

Changes:

- skip using `"-p"` option for `mldonkey_command`. It looks like do not accept the parameter, despite the documentation supports `"-p"` option.
- another approach to fix 'temp' fodler error during the 1st initialization phase.
- add extra servers and server.met options in `env` file.



