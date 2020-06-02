#!/bin/bash
func_exists=$(declare -f -F command_not_found_handle)
if [[ -z "$func_exists" ]]; then
  command_not_found_handle() {
    # Store and pop the potential command
    _INPUT_COMMAND="$1"
    shift 1


    _cachePath="$XDG_CACHE_HOME/command_not_found"
    [[ ! -d "$_cachePath" ]] && mkdir -p "$_cachePath" > /dev/null
    _cachePath="$_cachePath/$(echo "$PATH" | md5sum | sed -e 's/[^A-Za-z0-9]/_/g')"
    rm -f "$_cachePath"
    IFS=":"
    for p in $PATH; do
      if [[ -d "$p" ]]; then
        # The format of the file should be "executable|value"
        find "$p" -maxdepth 1 -executable -type f -not -regex ".*\..*" -printf "executable|%p\n" >> "$_cachePath"
      fi
    done

    _newCommand=$(fzf --query "$_INPUT_COMMAND" --select-1 --exit-0 --delimiter="\|" --with-nth=2 < "$_cachePath")
    case "$?" in
      0)
        # Normal
        readarray -td\| result < <(echo "${_newCommand}|");
        unset 'result[-1]'
        declare -p result > /dev/null
        case "${result[0]}" in
          executable)
            echo "${result[1]}" "$@"
            "${result[1]}" "$@"
            ;;
        esac
        ;;
      1)
        # No match
        echo "Could not find any potential command that matches '$_INPUT_COMMAND'"
        ;;
      2)
        # Error
        printf "%s: command not found!!!!!!!\n" "$_INPUT_COMMAND" >&2
        #echo "... something went terribly wrong..."
        ;;
      130)
        # Interrupted with Ctrl-C or ESC
        #echo "... okay, you didn't mean that..."
        ;;
      *)
        # no clue...
        printf "%s: command not found!!!!!!!\n" "$_INPUT_COMMAND" >&2
        #echo "...something went terribly, terribly wrong..."
        ;;
    esac
    unset IFS
    return 127
  }
fi

unset func_exists
