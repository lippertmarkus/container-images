# call update.sh in each directory
for d in */ ; do
    ( cd "$d" && ./update.sh ) &
done

wait
echo "all updates complete"