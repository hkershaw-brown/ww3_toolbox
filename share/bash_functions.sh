## bash functions
#
check_error () {
# stop and print error message if any error occurs
	if [ $? -ne 0 ]; then
		echo $1
		return 1
	else
		return 0
	fi
}

print_title () {
# print section title
	nl=${#1}
	str=`printf  '%.0s-' $(seq 1 $(( ${nl}+2 )))`
	echo " "
	echo " "
	echo "  +${str}+"
	echo "  | $1 |"
	echo "  +${str}+"
	echo " "
	echo " "
	return 0
}

find_replace () {
# find_replace STRING1 STRING2 FILE
# Find STRING1 in FILE and replace it by STRING2
	if [[ $# == 3 ]] && [[ -e ${3} ]]; then
		`sed "s/${1}/${2}/g" ${3} > ${3}.tmp`
		mv ${3}.tmp ${3}
		return 0
	else 
		return 1
	fi
}

