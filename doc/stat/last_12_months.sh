head -1 downloads.txt > last_12_months.txt
tail -12 downloads.txt >> last_12_months.txt
gnuplot downloads12.gp
rm last_12_months.txt
