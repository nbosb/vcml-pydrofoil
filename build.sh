#!/usr/bin/env bash
set -e

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

CONTAINER_PROGRAM=""
CONTAINER_PROGRAM_FLAGS=""

if command -v podman &> /dev/null; then
	CONTAINER_PROGRAM="podman"
	CONTAINER_PROGRAM_FLAGS="--userns keep-id"
	echo "Using podman"
elif command -v docker &> /dev/null; then
	CONTAINER_PROGRAM="docker"
	CONTAINER_PROGRAM_FLAGS="--user $(id -u):$(id -g)"
	echo "Using docker"
else
	echo "Error: No program found to launch the containers. Please install podman or docker."
	exit 1
fi

mkdir -p $DIR/build $DIR/images

IMAGE_NAME="vcml-pydrofoil-test"

echo "Building image..."
$CONTAINER_PROGRAM build -t "$IMAGE_NAME" "$DIR"

CFG_FILE="$1"

if [ -n "$CFG_FILE" ]; then
    CFG_BASENAME=$(basename "$CFG_FILE")

    echo "Running with config: $CFG_BASENAME"

    $CONTAINER_PROGRAM run \
        $CONTAINER_PROGRAM_FLAGS \
        --rm \
		-it \
        -v "$(dirname "$(realpath "$CFG_FILE")"):/configs:ro" \
        "$IMAGE_NAME" \
        "/configs/$CFG_BASENAME"
else
    echo "Running default configuration"

    $CONTAINER_PROGRAM run \
        $CONTAINER_PROGRAM_FLAGS \
        --rm \
		-it \
        "$IMAGE_NAME"
fi