_path=/home/linuxbrew/.linuxbrew/bin

if [[ -d "$_path" ]]; then
    if [[ ":$PATH" != *":$_path:"* ]]; then
        export PATH="$_path:$PATH"
    fi
fi

_path=/usr/local/opt/findutils/libexec/gnubin

if [[ -d "$_path" ]]; then
    if [[ ":$PATH" != *":$_path:"* ]]; then
        export PATH="$_path:$PATH"
    fi
fi

unset _path
