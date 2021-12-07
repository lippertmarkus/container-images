traefik_version=$(< version)

IMAGE_NAME="traefik:${traefik_version}"  # without repo
LINUX_PLATFORMS=""  # don't build for Linux but link official images with $APPENDIMAGELIST to manifest
WINBASE="mcr.microsoft.com/windows/nanoserver"
#WIN_TAGS=("1809" "1903" "1909" "2004" "20H2" "ltsc2022")
WIN_TAGS=("1809" "1903" "2004" "20H2" "ltsc2022")
APPENDIMAGELIST="traefik:${traefik_version}"  # with repo
ADDITIONAL_ARGS="--build-arg TRAEFIK_VERSION=${traefik_version}"