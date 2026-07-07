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
for PATTERN in "https" "http" "git" "://" "@"; do
    [[ "$URL" == "$PATTERN"* ]] && URL="${URL##"$PATTERN"}"
done
for PATTERN in "/" ".git"; do
    [[ "$URL" == *"$PATTERN" ]] && URL="${URL%%"$PATTERN"}"
done
printf "%s%s" "$ICON" "$URL"
