_path=$HOME/.fnm

if [[ -d "$_path" ]]; then
  prepend_path "${_path}"
  eval "`fnm env`"
fi

unset _path
