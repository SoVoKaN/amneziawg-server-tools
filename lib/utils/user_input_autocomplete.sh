default_value_autocomplete() {
    DEFAULT_VALUE="$1"

    QUESTION="$2"

    DEFAULT_VALUE_LENGTH="${#DEFAULT_VALUE}"

    QUESTION_LENGTH="${#QUESTION}"

    cursor_move_up "1"

    cursor_move_right "$QUESTION_LENGTH"

    printf "$DEFAULT_VALUE"

    cursor_move_down "1"

    cursor_move_left $((DEFAULT_VALUE_LENGTH + QUESTION_LENGTH))
}

handle_user_input() {
    read -r USER_INPUT

    USER_INPUT="${USER_INPUT#"${USER_INPUT%%[![:space:]]*}"}"
    USER_INPUT="${USER_INPUT%"${USER_INPUT##*[![:space:]]}"}"
}
