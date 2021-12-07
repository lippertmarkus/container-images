files=$(git diff --name-only HEAD~1)
echo "files changed: $files"

target_dirs=()

for file in $files ; do
    image_dir=$(dirname "$file")
    if [[ ! " ${target_dirs[*]} " =~ " ${image_dir} " ]] && [[ "$image_dir" =~ ^[^\.]+ ]]; then
        target_dirs+=("$image_dir")
    fi
done

# produce matrix array like [{"dir": "traefik", "version": "1809"}, ...]
json_matrix=""
for target_dir in $target_dirs; do
    . "$target_dir/build_config.sh"

    # add a target for each windows build
    for win_tag in ${WIN_TAGS[*]}; do
        json_matrix+="{\"dir\": \"$target_dir\", \"version\": \"$win_tag\"}, "
    done

    # add single matrix target for all linux builds
    if ! [ -z "$LINUX_PLATFORMS" ]; then
        json_matrix+="{\"dir\": \"$target_dir\", \"version\": \"$LINUX_PLATFORMS\"}, "
    fi
done
json_matrix=${json_matrix::-2}  # remove last comma and space

echo "matrix: [$json_matrix]"
echo "::set-output name=matrix::[$json_matrix]"