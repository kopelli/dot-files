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

    if [[ ! -s "$_cachePath" ]]; then
      IFS=":"
      for p in $PATH; do
        if [[ -d "$p" ]]; then
          # The format of the file should be "executable|value"
          find "$p" -maxdepth 1 -executable -not -regex ".*\..*" -printf "executable|%p\n" 2> /dev/null >> "$_cachePath"
        fi
      done
    fi

    _searchFile="$(mktemp "$XDG_CACHE_HOME/cnfh.XXX")"
    trap 'rm -f "$_searchFile"' 0 2 3 15
    cat "$_cachePath" >> "$_searchFile"

    _npmScripts="$(realpath "$(find-up "$PWD" -iname "package.json" | head -n 1)")"
    if [[ -s "$_npmScripts" ]]; then
      #echo "Need to add the scripts from $_npmScripts"
      jq --raw-output '.scripts | keys | map("npm|" + .) | reduce .[] as $script (""; . + "\n" + $script)' "$_npmScripts" 2>/dev/null >> "$_searchFile"
    fi

    _newCommand=$(fzf --query "$_INPUT_COMMAND" --select-1 --exit-0 --delimiter="\|" --with-nth=2 < "$_searchFile")
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
          npm)
            echo "...npm run ${result[1]}..." "$@"
            npm run "${result[1]}" "$@"
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
