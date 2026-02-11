get_terminal_rows() {
    TERMINAL_ROWS=$(stty -a | awk '{for (i = 1; i < NF; i++) if ($i == "rows") {v = $(i+1); out = ""; for (j = 1; j <= length(v); j++) {c = substr(v, j, 1); if (c >= "0" && c <= "9") out = out c} print out; exit}}')
}
