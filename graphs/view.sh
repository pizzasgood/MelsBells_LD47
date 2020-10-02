#!/bin/sh
head -n 500 graph.csv > minigraph.csv
./view.gnuplot
