_path=/usr/local/opt/dotnet/libexec

if [[ -d "$_path" ]]; then
  if [[ ":$PATH" != *":$_path:"* ]]; then
    export DOTNET_ROOT="$_path"
    export PATH="$PATH:$_path"
  fi
fi

unset _path
