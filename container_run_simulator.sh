#!/usr/bin/env bash
set -e

# If user specified a preference, try it. Use docker otherwise
CONTAINER_PROGRAM=${1:-docker}
CFG_FILE="$2"

if [[ "$CONTAINER_PROGRAM" == "docker" ]]; then

	if command -v docker &> /dev/null; then
		CONTAINER_PROGRAM_FLAGS="--user $(id -u):$(id -g)"
		echo "Using docker"
	else 
		echo "Docker was selected but it is not installed. Exiting..."
		exit 1
	fi
		
elif [[ "$CONTAINER_PROGRAM" == "podman" ]]; then

	if command -v podman &> /dev/null; then
		CONTAINER_PROGRAM_FLAGS="--userns keep-id"
		echo "Using podman"
	else 
		echo "Podman was selected but it is not installed. Exiting..."
		exit 1
	fi
else 
	echo "Invalid containerization option selected. Exiting..."
	echo "Usage: $0 [docker|podman]"
	exit 1
fi

IMAGE_NAME="vcml-pydrofoil:latest"

# If the cfg file was provided, this overwrites the one specified in the Dockerfile
if [[ -n "$CFG_FILE" ]]; then
    CFG_BASENAME=$(basename "$CFG_FILE")

    $CONTAINER_PROGRAM run \
        $CONTAINER_PROGRAM_FLAGS \
        --rm \
        -it \
        -v "$(dirname "$(realpath "$CFG_FILE")"):/configs:ro" \
        "$IMAGE_NAME" \
        "$CFG_BASENAME"
else
    $CONTAINER_PROGRAM run \
        $CONTAINER_PROGRAM_FLAGS \
        --rm \
        -it \
        "$IMAGE_NAME"
fi