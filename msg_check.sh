./msg_check.tcl
for i in eng_*.txt ceng_*.txt
do
	if [ -f $i ] && [ -s  $i ]
	then
		echo "**********************************************"
		echo "Check message file ($i)"
		echo "**********************************************"
	fi
done
