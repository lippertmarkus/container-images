# check for updates newer than in "version" file, if available, update that file

{ version=$(< version); } 2> /dev/null

echo "checking updates for traefik!"
latest=$(curl -sL "https://api.github.com/repos/traefik/traefik/releases/latest" | jq -r ".tag_name")

if [ ! -z "$latest" ] && [ "$latest" != "null" ] && [[ "$version" != "$latest" ]]; then
    echo "New version available!"
    echo $latest > version
fi