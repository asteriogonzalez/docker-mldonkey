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

- skip using "-p" option for mldonkey_command as seems do not accept the parameter.
- fix 'temp' error in the 1st initialization phase.
- add extra servers and server.met
 

