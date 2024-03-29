# _!!_ Contents within this block are managed by 'conda init' _!!_
__conda_setup="$('$HOME/opt/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/opt/anaconda3/etc/profile.d/conda.sh"
    else
      prepend_path "$HOME/opt/anaconda3/bin"
    fi
fi
unset __conda_setup

