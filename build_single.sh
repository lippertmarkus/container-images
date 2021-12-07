# input variables:
#BUILD_DIR="traefik"
#REPOSITORY="lippertmarkus"

set -e

if [ -z "$BUILD_DIR" ] || [ -z $REPOSITORY ]; then
    echo "BUILD_DIR=$BUILD_DIR or REPOSITORY=$REPOSITORY not set"
    exit 1
fi

cd $BUILD_DIR
. build_config.sh

TARGETIMAGE="$REPOSITORY/$IMAGE_NAME"
MANIFESTLIST=""

echo "Building image $TARGETIMAGE"


# build for Linux
if ! [ -z "$LINUX_PLATFORMS" ]; then
    echo "Building for Linux: $LINUX_PLATFORMS"
    docker buildx build --platform $LINUX_PLATFORMS --push --pull --target linux $ADDITIONAL_ARGS -t $TARGETIMAGE .
fi

# build for Windows
for VERSION in ${WIN_TAGS[*]}
do 
    echo "Building Windows $VERSION"
    docker buildx build --platform windows/amd64 --push --pull --build-arg WINBASE=${WINBASE}:${VERSION} --build-arg WINTAG=${VERSION} --target windows $ADDITIONAL_ARGS -t "${TARGETIMAGE}-${VERSION}" .
    MANIFESTLIST+="${TARGETIMAGE}-${VERSION} "
done

echo "Creating manifest with Windows and optionally Linux and additional images"
docker manifest rm $TARGETIMAGE > /dev/null 2>&1 || true

if ! [ -z "$LINUX_PLATFORMS" ]; then
    lin_images_prep=$(docker manifest inspect $TARGETIMAGE | jq -r '.manifests[].digest')
    lin_images=${lin_images//sha256:/${TARGETIMAGE%%:*}@sha256:}
fi

if ! [ -z "$APPENDIMAGELIST" ]; then
    add_images_prep=$(docker manifest inspect $APPENDIMAGELIST | jq -r '.manifests[].digest')
    add_images=${add_images_prep//sha256:/${APPENDIMAGELIST%%:*}@sha256:}
fi

echo "DEBUG manifest list: $MANIFESTLIST $lin_images $add_images"
docker manifest create $TARGETIMAGE $MANIFESTLIST $lin_images $add_images

echo "Annotating Windows versions to manifest"
for VERSION in ${WIN_TAGS[*]}
do 
  docker manifest rm ${WINBASE}:${VERSION} > /dev/null 2>&1 || true
  full_version=`docker manifest inspect ${WINBASE}:${VERSION} | grep "os.version" | head -n 1 | awk '{print $$2}' | sed 's@.*:@@' | sed 's/"//g'`  || true; 
  docker manifest annotate --os-version ${full_version} --os windows --arch amd64 ${TARGETIMAGE} "${TARGETIMAGE}-${VERSION}"
done

echo "Pushing manifest"
docker manifest push $TARGETIMAGE