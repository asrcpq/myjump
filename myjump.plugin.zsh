source ${0:A:h}/myjump.zsh
mkdir -p "$XDG_DATA_HOME"/myjump
MYJUMP_FILE="$XDG_DATA_HOME"/myjump/data
touch "$MYJUMP_FILE"
while read -r line; do
	MYJUMP_DATA+=($line)
done <$MYJUMP_FILE
autoload -U add-zsh-hook
add-zsh-hook precmd myjump_precmd
zle -N myjump_precmd
