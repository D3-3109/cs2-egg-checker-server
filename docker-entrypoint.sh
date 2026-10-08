#!/bin/sh
# Converts environment variables into command line arguments.
# Any extra arguments passed after the image name are forwarded verbatim.
set -e

if [ -n "${DBPATH:-}" ]; then
	set -- -dbpath "$DBPATH" "$@"
fi

if [ -n "${LISTEN:-}" ]; then
	set -- -listen "$LISTEN" "$@"
fi

exec /app/cs2-egg-checker-server "$@"
