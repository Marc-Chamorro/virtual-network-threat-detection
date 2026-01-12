# Script to be executed every time the environment starts
# Useful to start services for the servers and similar ones

#!/bin/sh

echo "Machine running"

# https://stackoverflow.com/questions/56586562/how-to-source-an-entry-point-script-with-docker
exec "$@"