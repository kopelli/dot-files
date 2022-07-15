_path=/usr/local/opt/python@3.10/libexec/bin

if [[ -d "$_path" ]]; then
  if [[ ":$PATH" != *":$_path:"* ]]; then
    export PATH="$_path:$PATH"
  fi
fi

_path=/usr/local/opt/python@3.10/bin
if [[ -d "$_path" ]]; then
  if [[ ":$PATH" != *":$_path:"* ]]; then
    export PATH="$_path:$PATH"
  fi
fi


unset _path
