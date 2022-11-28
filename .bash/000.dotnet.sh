_path=/usr/local/opt/dotnet/libexec

if [[ -d "$_path" ]]; then
  export DOTNET_ROOT="$_path"
  prepend_path "$_path"
fi

unset _path
