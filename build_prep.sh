target_dirs=()

if [ -z "$MANUAL_IMAGE" ]; then
    files=$(git diff $(git log -1 --before=@{last.hour} --format=%H) --name-only --stat)
    echo "files changed: $files"

    for file in $files ; do
        image_dir=$(dirname "$file")
        if [[ ! " ${target_dirs[*]} " =~ " ${image_dir} " ]] && [[ "$image_dir" =~ ^[^\.]+ ]]; then
            target_dirs+=("$image_dir")
        fi
    done
else
    target_dirs+=("$MANUAL_IMAGE")
fi

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

out_array=$(printf '%s\n' "${target_dirs[@]}" | jq -R . | jq -s --compact-output .)
echo "target dirs: $out_array"
echo "::set-output name=matrix_dirs::$out_array" 