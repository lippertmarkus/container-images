# input variables:
#BUILD_DIR="traefik"
#REPOSITORY="lippertmarkus"
#VERSION="1809" or "linux/amd64,linux/arm64,..."

set -e

if [ -z "$BUILD_DIR" ] || [ -z $REPOSITORY ] || [ -z $VERSION ]; then
    echo "BUILD_DIR=$BUILD_DIR or REPOSITORY=$REPOSITORY or VERSION=$VERSION not set"
    exit 1
fi

cd $BUILD_DIR
. build_config.sh

TARGETIMAGE="$REPOSITORY/$IMAGE_NAME"
echo "Building image $TARGETIMAGE"

if [[ "$VERSION" == linux* ]]; then
    # build for Linux
    echo "Building for Linux: $VERSION"
    docker buildx build --platform $VERSION --cache-from "type=local,src=/tmp/.buildx-cache" --cache-to "type=local,dest=/tmp/.buildx-cache" --push --pull --target linux $ADDITIONAL_ARGS -t $TARGETIMAGE .
else
    # build for Windows
    echo "Building for Windows Version $VERSION"
    docker buildx build --platform windows/amd64 --cache-from "type=local,src=/tmp/.buildx-cache" --cache-to "type=local,dest=/tmp/.buildx-cache" --push --pull --build-arg WINBASE=${WINBASE}:${VERSION} --build-arg WINTAG=${VERSION} --target windows $ADDITIONAL_ARGS -t "${TARGETIMAGE}-${VERSION}" .
fi

