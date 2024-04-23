# drh
DrHook statistics

This project provides some small tools for working on statistics based on DrHook output, except for mem.sh and memprof.sh, where graphical views are made for memory from Unix commands.

Remark: memprof.sh relies on an R package, mfnode, which is on Github. You may install it before using memprof.sh and define one of R's environment variables (R_LIBS_USER or R_LIBS) pointing at this installation location.


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

4 drtime.sh

This script uses drtot.txt, produced by drh.sh, and produces PNG graphics showing total times for a set of functions present as tags in DrHook files.
Tags are supplied via a simple text file where the 1st tag is used as a function englobing the others.
2 graphics are produced:
- one for times for the 1st tag as stacking the others
- the other for unstaacked times

Both graphics are shown by MPI task.

5 mem.sh/memprof.sh

These 2 scripts produce a graphical view of evolution of memory with time. They read a text file resulting from a background process of commands top or free during the execution of a binary (the model for instance).

Graphics show results for either 1 or several MPI tasks.
