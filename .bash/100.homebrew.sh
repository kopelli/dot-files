_path=/home/linuxbrew/.linuxbrew/bin

if [[ -d "$_path" ]]; then
    if [[ ":$PATH" != *":$_path:"* ]]; then
        export PATH="$PATH:$_path"
    fi
fi

unset _path