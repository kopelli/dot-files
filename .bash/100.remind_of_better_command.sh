remind_of_better_command() (
    local command_name=$1
    local better_command=$2

    local cache_time="$XDG_CACHE_HOME/command_last_executed.sh"

    local epoch_seconds=$(date +%s)
    local -A LAST_EXECUTED_TIME
    if [[ -r $cache_time ]]; then
        # The cache time file exists, so bring the content into the environment
        source $cache_time
    fi

    # See the "missing keys" section of https://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/
    # to help understand the syntax...
    if [ ! ${LAST_EXECUTED_TIME[$command_name]+_} ]; then
        # The command doesn't exist yet,
        # so set a default value so we can perform math on it later
        LAST_EXECUTED_TIME[$command_name]=0
    fi

    # Since we don't want to constantly spam us with a reminder, limit it to at most once an hour
    if [[ $(echo "$epoch_seconds - ${LAST_EXECUTED_TIME[$command_name]}" | bc) -ge 3600 ]]; then
        LAST_EXECUTED_TIME[$command_name]=$epoch_seconds
        local RED='\033[0;31m'
        local NO_COLOR='\033[0m'
        echo -e "${RED}REMINDER${NO_COLOR} -- '$better_command' exists as an alternative to '$command_name'..."
        declare -p LAST_EXECUTED_TIME > $cache_time
    fi

    shift 2

    $command_name $@
)