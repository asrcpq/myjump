trap myjump_exit EXIT

myjump_init() {
	autoload -U add-zsh-hook
	mkdir -p "$XDG_DATA_HOME"/myjump
	MYJUMP_FILE="$XDG_DATA_HOME"/myjump/data
	touch "$MYJUMP_FILE"
	while read -r line; do
		MYJUMP_DATA+=($line)
	done <$MYJUMP_FILE
	add-zsh-hook precmd myjump_precmd
	zle -N myjump_precmd
}

myjump_exit() {
	for each_pwd in $NEW_DATA; do
		echo "$each_pwd" >> "$MYJUMP_FILE"
	done
}

myjump_precmd() {
	if [ "$PWD" = "$HOME" ]; then
		return
	fi
	if [ "$PWD" = "$LASTPWD" ]; then
		return
	fi
	if [ ${#PWD} -ge 512 ]; then
		return
	fi
	NEW_DATA+=("${"${PWD//\\/\\\\}"//$'\n'/\\\\n}")
	LASTPWD="$PWD"
}

myjump_compress() {
	set -e
	tac "$MYJUMP_FILE" | awk '!seen[$0]++' | tac | sponge "$MYJUMP_FILE"
}

# list nonexist
myjump_lnx() {
	set -e
	cat "$MYJUMP_FILE" | while read -r line; do
		if [ ! -d "$(printf '%b' "$line")" ]; then
			echo $line
		fi
	done
}

myjump() {
	setopt nocasematch
	setopt local_options BASH_REMATCH
	param="$@"
	for ((idx=${#NEW_DATA};idx>0;idx--)); do
		if [[ "$NEW_DATA[idx]" =~ ^(.*${param// /.*}[^/]*).*$ ]]; then
			if [ -d "${BASH_REMATCH[2]}" ]; then
				cd "${BASH_REMATCH[2]}"
				return
			fi
		fi
	done
	for ((idx=${#MYJUMP_DATA};idx>0;idx--)); do
		if [[ "$MYJUMP_DATA[idx]" =~ ^(.*${param// /.*}[^/]*).*$ ]]; then
			local unescaped="$(printf "%b" ${BASH_REMATCH[2]})"
			if [ -d "${unescaped}" ]; then
				cd "${unescaped}"
				return
			fi
		fi
	done
	return 1
}
