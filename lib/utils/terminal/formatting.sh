clean_lines() {
    NUM="0"
    while [ "$NUM" -lt "$1" ]; do
        printf '\033[1A'
        printf '\033[2K'

        NUM=$((NUM + 1))
    done
}

print_dashes() {
    NUM="0"
    while [ "$NUM" -lt "$1" ]; do
        printf "-"

        NUM=$((NUM + 1))
    done

    printf "\n"
}
