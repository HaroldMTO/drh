# drh
DrHook statistics
This project provides 3 small tools for working on statistics based on DrHook output.

1 drh.sh
This tool gathers information from DrHook profiling files into 2 separate files:
- drself.txt relative to self timings
- drtot.txt relative to total timings

2 drdiff.sh
This tool compares results from previous calls to drh.sh. Comparison is made on files drself.txt and drtot.txt produced by drh.sh that can be found into 2 directories. It then produces 2 separate files:
- self.txt relative to self statistics (from drself.txt)
- tot.txt relative to total statictics (from drtot.txt)

3 wall.sh
This tool produces graphs for some tags present in DrHook statistics file. Tags are expressed (ie selected) in terms of a REGEX pattern. One first graph produced shows execution times for all MPI tasks present in the DrHook statistics file. If relevant, another graph shows the same timings but taking into account OpenMP threads
