#!/bin/bash

######################################################################
# Template
######################################################################
set -o errexit  # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset  # Exit if variable not set.
IFS=$'\n\t'     # Remove the initial space and instead use '\n'.

# load environment variables from `secrets.env` file
source secrets.env

# build the Docker images, stop any running containers, and start them up in detached mode
docker compose build && docker compose down && docker compose up -d
