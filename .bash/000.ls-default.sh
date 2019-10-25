# Modifying this from https://stackoverflow.com/a/1688464
if ls --color -d . >/dev/null 2>&1; then
  LS_SUPPORT=gnu
  alias ls='ls -l -A -p -G -v --color'
elif ls -G -d . >/dev/null 2>&1; then
  LS_SUPPORT=bsd
  alias ls='ls -l -A -p -G -v'
else
  LS_SUPPORT=solaris
  alias ls='ls -l -A'
fi

LS_COLORS=$LS_COLORS:'di=1;36:' ; export LS_COLORS