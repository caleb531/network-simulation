# CS 436 Network Simulation
*Copyright 2016 Caleb Evans, Kyle Gullicksen*

For this school project, we were given a network topology to describe and
implement using TCL. We then ran our file through the `ns2` network simulator to
generate a `.tr` file containing many lines of trace data (amount transferred,
packets sent/received, etc.). We processed this trace file using AWK to gather
data for average throughput, jitter, and other metrics for several different
source-destination pairs.
