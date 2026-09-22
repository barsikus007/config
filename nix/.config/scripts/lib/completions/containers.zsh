local -a _rows
_rows=(${(f)"$(docker ps --format '{{.Names}}' 2>/dev/null)"})
compadd -- $_rows
