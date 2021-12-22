NR == 1 { print $0 }
NR > 1 { split($1, ym, "-");
    y = ym[1]
    for (i=2; i <= NF; i++) {
        years[y][i] += $i;
    }
}
END { for (i in years) {
        printf "%d", i
        for (j in years[i]) {
            printf " %d", years[i][j];
        }
        printf "\n";
      }
}
