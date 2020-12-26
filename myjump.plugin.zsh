source ${0:A:h}/myjump.zsh
mkdir -p $HOME/.local/share/myjump
MYJUMP_FILE=$HOME/.local/share/myjump/data
while read -r line; do
	MYJUMP_DATA+=($line)
done <$MYJUMP_FILE
autoload -U add-zsh-hook
add-zsh-hook precmd myjump_precmd
zle -N myjump_precmd
