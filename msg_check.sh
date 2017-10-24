./msg_check.tcl
if [ -f ./hun_ger.txt ] && [ -s ./hun_ger.txt ]
then
	echo "**********************************************"
	echo "Check GeoEasy german message file (hun_ger.txt)"
#	cat ./hun_ger.txt
	echo "**********************************************"
fi
if [ -f ./hun_eng.txt ] && [ -s ./hun_eng.txt ]
then
	echo "**********************************************"
	echo "Check GeoEasy english message file (hun_eng.txt)"
#	cat ./hun_eng.txt
	echo "**********************************************"
fi
if [ -f ./chun_ger.txt ] && [ -s ./chun_ger.txt ]
then
	echo "**********************************************"
	echo "Check ComEasy german message file (chun_ger.txt)"
#	cat ./chun_ger.txt
	echo "**********************************************"
fi
if [ -f ./chun_eng.txt ] && [ -s ./chun_eng.txt ]
then
	echo "**********************************************"
	echo "Check ComEasy english message file (chun_eng.txt)"
#	cat ./chun_eng.txt
	echo "**********************************************"
fi
