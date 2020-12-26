trap myjump_exit EXIT
myjump_exit() {
	for each_pwd in $NEW_DATA; do
		echo $each_pwd >> $MYJUMP_FILE
	done
}

myjump_precmd() {
	if [ $#PWD -ge 512 ]; then
		return
	fi
	if [ "$PWD" = "$LASTPWD" ]; then
		return
	fi
	NEW_DATA+=("$(printf "%q" $PWD)")
	LASTPWD=$PWD
}

myjump_compress() {
	set -e
	awk '!seen[$0]++' $MYJUMP_FILE | sponge $MYJUMP_FILE
}

myjump() {
	param="$@"
	for each_pwd in $NEW_DATA; do
		if [[ $each_pwd =~ ^.*${param// /.*}.*$ ]]; then
			cd $each_pwd
			return
		fi
	done
	for ((idx=${#MYJUMP_DATA}-1;idx>0;idx--)); do
		if [[ $MYJUMP_DATA[idx] =~ ^.*${param// /.*}.*$ ]]; then
			cd $MYJUMP_DATA[idx]
			return
		fi
	done
	return 1
}
