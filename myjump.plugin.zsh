source ${0:A:h}/myjump.zsh
autoload -Uz add-zsh-hook
add-zsh-hook zshexit _myjump_exit
_myjump_init
unset _myjump_init
