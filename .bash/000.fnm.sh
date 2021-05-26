_path=$HOME/.fnm

if [[ -d "$_path" ]]; then
    if [[ ":$PATH" != *":$_path:"* ]]; then
        export PATH="$_path:$PATH"
        eval "`fnm env`"
    fi
fi

unset _path
