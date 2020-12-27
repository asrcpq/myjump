trap myjump_exit EXIT
myjump_exit() {
	for each_pwd in $NEW_DATA; do
		echo $each_pwd >> $MYJUMP_FILE
	done
}

myjump_precmd() {
	if [ "$PWD" = "$HOME" ]; then
		return
	fi
	if [ "$PWD" = "$LASTPWD" ]; then
		return
	fi
	if [ $#PWD -ge 512 ]; then
		return
	fi
	NEW_DATA+=("$(printf "%q" $PWD)")
	LASTPWD=$PWD
}

myjump_compress() {
	set -e
	tac $MYJUMP_FILE | awk '!seen[$0]++' | tac | sponge $MYJUMP_FILE
}

myjump() {
	param="$@"
	for ((idx=${#NEW_DATA};idx>0;idx--)); do
		if [[ $NEW_DATA[idx] =~ ^.*${param// /.*}.*$ ]]; then
			cd $NEW_DATA[idx]
			return
		fi
	done
	for ((idx=${#MYJUMP_DATA};idx>0;idx--)); do
		if [[ $MYJUMP_DATA[idx] =~ ^.*${param// /.*}.*$ ]]; then
			cd $MYJUMP_DATA[idx]
			return
		fi
	done
	return 1
}
