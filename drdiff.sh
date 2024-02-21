#!/bin/sh

drh=~/util/drh

set -e

if echo $* | grep -qE '(^| +)-\w*h'
then
	echo "usage: drdiff DIR1 [DIR2] [-h]
	DIR[i] are directories containing files produced by drh.sh (drself.txt and drtot.txt)
	DIR1 points to the reference job, DIR2 points to the job to compare (default: '.')"
	exit
elif [ $# -eq 0 ]
then
	echo "error: usage" >&2
	exit 1
fi

d1=$1
[ $# -gt 1 ] && d2=$2 || d2=.

ls -d $d1 $d2 >/dev/null

if [ $d1/drself.txt -nt self.txt ] || [ $d2/drself.txt -nt self.txt ]
then
	type R >/dev/null 2>&1 || module load -s intel R >/dev/null 2>&1

	R --slave -f $drh/drdiff.R --args $d1/drself.txt $d2/drself.txt > self.txt
	R --slave -f $drh/drdiff.R --args $d1/drtot.txt $d2/drtot.txt > tot.txt
fi
