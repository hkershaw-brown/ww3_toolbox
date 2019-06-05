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

function GetDayOfYear ()
{
# never ask for leap day so mar 1 is always day 60 and all years are 365 days long
  month=$1
  day=$2

# arrays are indexed from 0, lastday is last day of previous month
# hence lastday[1]=0 is last day of December
# hence lastday[2]=31 is last day of January
  lastday=(0 0 31 59 90 120 151 181 212 243 273 304 334 365)

  jd=$((${lastday[(($month))]}+$day));

  echo $jd
}



