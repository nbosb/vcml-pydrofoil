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

$CONTAINER_PROGRAM build --tag vcml-pydrofoil-test .

$CONTAINER_PROGRAM run \
    $CONTAINER_PROGRAM_FLAGS \
    --rm  -it  vcml-pydrofoil-test