func_exists=`declare -f -F command_not_found_handle`
if [[ -n "$func_exists" ]]; then
  command_not_found_handle() {
    # dig into https://github.com/search?q=command_not_found_handle&type=Code for further ideas
    printf "%s: command not found!!!!!!!\n" "$1" >&2
    return 127
  }
fi

unset func_exists
