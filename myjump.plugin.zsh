source ${0:A:h}/myjump.zsh
autoload -Uz add-zsh-hook
add-zsh-hook zshexit myjump_exit
myjump_init
