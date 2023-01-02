_myjump_load() {
	_MYJUMP_FILE="$XDG_SRC_HOME"/asrcpq/myjump/data
	touch "$_MYJUMP_FILE"
	unset _MYJUMP_DATA
	while read -r line; do
		_MYJUMP_DATA+=($line)
	done <$_MYJUMP_FILE
}

_myjump_init() {
	autoload -U add-zsh-hook
	_myjump_load
	add-zsh-hook precmd _myjump_precmd
	zle -N _myjump_precmd
}

_myjump_exit() {
	for each_pwd in $_MYJUMP_NEW_DATA; do
		echo "$each_pwd" >> "$_MYJUMP_FILE"
	done
}

_myjump_precmd() {
	if [ "$PWD" = "$HOME" ]; then
		return
	fi
	if [ "$PWD" = "$LASTPWD" ]; then
		return
	fi
	if [ ${#PWD} -ge 512 ]; then
		return
	fi
	_MYJUMP_NEW_DATA+=("${"${PWD//\\/\\\\}"//$'\n'/\\\\n}")
	LASTPWD="$PWD"
}

myjump_compress() {
	[ -f "$_MYJUMP_FILE.tmp" ] && return 1
	tac "$_MYJUMP_FILE" | awk '!seen[$0]++' | tac > "$_MYJUMP_FILE.tmp"
	wc -l <"$_MYJUMP_FILE" | tr -d '\n'
	echo -n " -> "
	wc -l <"$_MYJUMP_FILE.tmp"
	mv -f "$_MYJUMP_FILE.tmp" "$_MYJUMP_FILE"
}

# manual clean nonexist
myjump_cnx() {
	local cnt=0
	_myjump_load # reload to update data
	for line in $_MYJUMP_DATA; do
		cnt=$((cnt + 1))
		echo -n "\r$cnt"
		if [ -n "$1" ] && [[ "$line" =~ $1 ]] || [ -d "$(printf '%b' "$line")" ]; then
			echo "${"${line//\\/\\\\}"//$'\n'/\\n}" >> "$_MYJUMP_FILE.tmp"
		else
			echo "$line"
		fi
	done

	mv "$_MYJUMP_FILE.tmp" "$_MYJUMP_FILE"
	rm -f "$_MYJUMP_FILE.tmp"
}

myjump() {
	setopt nocasematch
	setopt local_options BASH_REMATCH
	param="$@"
	for ((idx=${#_MYJUMP_NEW_DATA};idx>0;idx--)); do
		if [[ "$_MYJUMP_NEW_DATA[idx]" =~ ^(.*${param// /.*}[^/]*).*$ ]]; then
			if [ -d "${BASH_REMATCH[2]}" ]; then
				cd "${BASH_REMATCH[2]}"
				return
			fi
		fi
	done
	for ((idx=${#_MYJUMP_DATA};idx>0;idx--)); do
		if [[ "$_MYJUMP_DATA[idx]" =~ ^(.*${param// /.*}[^/]*).*$ ]]; then
			local unescaped="$(printf "%b" ${BASH_REMATCH[2]})"
			if [ -d "${BASH_REMATCH[2]}" ]; then
				cd "${unescaped}"
				return
			fi
		fi
	done
	return 1
}
