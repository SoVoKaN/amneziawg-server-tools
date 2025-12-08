cursor_move_up() {
    printf '\033[%sA' "$1"
}

cursor_move_down() {
    printf '\033[%sB' "$1"
}

cursor_move_left() {
    printf '\033[%sD' "$1"
}

cursor_move_right() {
    printf '\033[%sC' "$1"
}
