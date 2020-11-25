# Set the 'history' command to show when the previous commands were executed
HISTTIMEFORMAT="[%F %T] "

# Append history across sessions
shopt -s histappend

# Verify that history can be appended, or recover if something goes wrong
shopt -s histreedit
shopt -s histverify

# Ignore history commands that start with whitespace or duplicate commands
HISTCONTROL='ignoreboth'

##if [[ $PROMPT_COMMAND != *"history -c;"* ]]; then
#    # Commit history for the window, clear history, and reload all history before showing the prompt
#    PROMPT_COMMAND="history -a;history -c;history -r;$PROMPT_COMMAND"
#fi
