URL=$(git ls-remote --get-url)
if [[ "$URL" =~ "github" ]]; then
    ICON=" "
elif [[ "$URL" =~ "gitlab" ]]; then
    ICON=" "
elif [[ "$URL" =~ "bitbucket" ]];then
    ICON=" "
elif [[ "$URL" =~ "kernel" ]];then
    ICON=" "
elif [[ "$URL" =~ "archlinux" ]];then
    ICON=" "
elif [[ "$URL" =~ "gnu" ]];then
    ICON=" "
elif [[ "$URL" =~ "git" ]];then
    ICON=" "
else
    ICON=" "
    URL="localhost"
fi
if [[ "$URL" == *"://"* ]]; then
    #? explicit scheme, e.g. ssh://git@host/path or https://host/path
    SCHEME="${URL%%://*}"
    URL="${URL#*://}"
    URL="${URL#*@}"
    if [[ "$SCHEME" != "http" && "$SCHEME" != "https" ]]; then
        URL="${URL#*/}"
        URL="$SCHEME:$URL"
    fi
else
    #? scp-like syntax, e.g. git@host:path
    URL="${URL#*@}"
    URL="${URL#*:}"
fi
for PATTERN in "/" ".git"; do
    [[ "$URL" == *"$PATTERN" ]] && URL="${URL%%"$PATTERN"}"
done
printf "%s%s" "$ICON" "$URL"
