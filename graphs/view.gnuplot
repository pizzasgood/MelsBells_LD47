#!/bin/env -S gnuplot -p
set datafile separator ','
plot 'minigraph.csv' with lines
