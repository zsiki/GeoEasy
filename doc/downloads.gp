#!/usr/bin/gnuplot
#
# Plotting downloads statistics (see downloads.txt)
#
# AUTHOR: zvezdochiot

set terminal png font "Verdana,8" size 950, 520

set title 'Downloads 2017 October - 2019 March'
set xlabel ' '
set ylabel 'Count'

#set key below center horizontal noreverse enhanced autotitle box
set key at graph 0.25, 0.95 noreverse enhanced autotitle box

set timefmt '%Y-%m'
set xdata time
set format x "%b %Y"

set xrange ['2017-10':'2019-03']
#set xtics '2017-10', 8640000, '2019-03'
set xtics '2017-10', 2700000, '2019-03'
set mxtics 1
set xtic rotate by 45 scale 0 offset character -4,-2.5
set style data linespoints

set terminal png enhanced
set output 'downloads.png'
plot 'downloads.txt' using 1:2 linestyle 1 title '3.0.0', \
     '' using 1:3 linestyle 2 title '3.0.1', \
     '' using 1:4 linestyle 3 title '3.0.2', \
     '' using 1:5 linestyle 4 title '3.0.3', \
     '' using 1:6 linestyle 5 title '3.1.0', \
     '' using 1:7 linestyle 6 title '3.1.1', \
     '' using 1:8 linestyle 7 linewidth 3 title 'all'

# set terminal xterm
# replot
