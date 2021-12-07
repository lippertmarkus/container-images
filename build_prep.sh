files=$(git diff --name-only HEAD~1)

target_dirs=()

for file in $files ; do
    image_dir=$(dirname "$file")
    if [[ ! " ${target_dirs[*]} " =~ " ${image_dir} " ]] && [[ "$image_dir" =~ ^[^\.]+ ]]; then
        target_dirs+=("$image_dir")
    fi
done

out_array=$(printf '%s\n' "${target_dirs[@]}" | jq -R . | jq -s --compact-output .)
echo "::set-output name=matrix::{\"dir\": $out_array}"