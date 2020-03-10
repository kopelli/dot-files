_path=$HOME/.rvm/bin

if [[ -d "$_path" ]]; then
    if [[ ":$PATH" != *":$_path:"* ]]; then
        export PATH="$PATH:$_path"
    fi
fi

unset _path