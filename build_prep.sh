files=$(git diff --name-only HEAD~1)
echo "files changed: $files"

target_dirs=()

for file in $files ; do
    image_dir=$(dirname "$file")
    if [[ ! " ${target_dirs[*]} " =~ " ${image_dir} " ]] && [[ "$image_dir" =~ ^[^\.]+ ]]; then
        target_dirs+=("$image_dir")
    fi
done

out_array=$(printf '%s\n' "${target_dirs[@]}" | jq -R . | jq -s --compact-output .)
echo "target dirs: $out_array"
echo "::set-output name=matrix::$out_array"