#!/bin/bash

set -e

isLikelyTox=
case "$1" in
	run | r | run-parallel | p | depends | de | list | l | devenv | d | config | c | quickstart | q | exec | e | legacy | le ) isLikelyTox=1 ;;
esac

# First arg is `-v` or `--some-option`.
# Or if our command is a valid tox subcommand, let's invoke it through tox instead.
# This allows for "docker run 31z4/tox run-parallel", etc.
if [ "${1#-}" != "$1" ] || [ -n "$isLikelyTox" ]; then
	set -- tox "$@"
fi

exec "$@"