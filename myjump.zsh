myjump_load() {
	mkdir -p "$XDG_DATA_HOME"/myjump
	MYJUMP_FILE="$XDG_DATA_HOME"/myjump/data
	touch "$MYJUMP_FILE"
	unset MYJUMP_DATA
	while read -r line; do
		MYJUMP_DATA+=($line)
	done <$MYJUMP_FILE
}

myjump_init() {
	autoload -U add-zsh-hook
	myjump_load
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

# manual clean nonexist
myjump_cnx() {
	local cnt=0
	local yn
	if [ -f "$MYJUMP_FILE.tmp" ]; then
		echo "rm \"$MYJUMP_FILE.tmp\""
		return 1
	fi
	myjump_load # reload to update data
	for line in $MYJUMP_DATA; do
		local PRESERVE_FLAG=true
		cnt=$((cnt + 1))
		echo -n "\r$cnt"
		if [ ! -d "$(printf '%b' "$line")" ]; then
			echo -n ":$line not exist, delete?(yN)"
			read -r yn
			if [ "$yn" = "y" ]; then
				PRESERVE_FLAG=false
			fi
			RESULT+="$line\n"
		fi
		if $PRESERVE_FLAG; then
			echo "${"${line//\\/\\\\}"//$'\n'/\\n}" >> "$MYJUMP_FILE.tmp"
		fi
	done
	mv "$MYJUMP_FILE.tmp" "$MYJUMP_FILE"
}

myjump() {
	setopt nocasematch
	setopt local_options BASH_REMATCH
	param="$@"
	for ((idx=${#NEW_DATA};idx>0;idx--)); do
		if [[ "$NEW_DATA[idx]" =~ ^(.*${param// /.*}[^/]*).*$ ]]; then
			cd "${BASH_REMATCH[2]}"
			return
		fi
	done
	for ((idx=${#MYJUMP_DATA};idx>0;idx--)); do
		if [[ "$MYJUMP_DATA[idx]" =~ ^(.*${param// /.*}[^/]*).*$ ]]; then
			local unescaped="$(printf "%b" ${BASH_REMATCH[2]})"
			cd "${unescaped}"
			return
		fi
	done
	return 1
}
