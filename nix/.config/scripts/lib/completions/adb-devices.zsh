local -a _rows _serials
_rows=(${(f)"$(adb devices 2>/dev/null)"})
(( $#_rows > 1 )) && _serials=(${${_rows[2,-1]}%%[[:space:]]*})
compadd -- $_serials
