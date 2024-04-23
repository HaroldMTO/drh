#!/bin/sh

drh=~/util/drh

usage()
{
	echo "Description:
	Produce plots of DrHook accumulated total time for a set of routines

Usage:
	drtime.sh FILE [DRFILE] [-w] [-v] [-h]

Options:
	FILE: short text file listing tags (roughly, function names) to be found in DRFILE
	DRFILE: path to a file produced by drh.sh (defaults to 'drtot.txt')
	-w: search for tags in DRFILE as whole words (like grep -w)
	-v: verbose mode
	-h: print this help message and exit normally

Details:
	FILE is mandatory and is a positional argument (\$1).
	The 1st tag in FILE is considered as a tag which DrHook time encompasses time of \
all the other tags. On the contrary, times for other tags than this 1st one are \
considered to be non overlapping times, so that stacking these times has some meaning.
"
}

set -e

if [ $# -eq 0 ]
then
	usage
	exit
fi

flist=""
fhook=drtot.txt
opt=""
while [ $# -gt 0 ]
do
	case $1 in
	-h)
		usage
		exit
		;;
	-v)
		opt=verbose
		;;
	*)
		if [ -z "$flist" ]
		then
			flist=$1
		else
			fhook=$1
		fi
		;;
	esac

	shift
done

ls $flist >/dev/null
ls $fhook >/dev/null

[ $(basename $fhook) = "drtot.txt" ] || echo "alternate file: $fhook"

type R >/dev/null 2>&1 || module load -s intel R >/dev/null 2>&1

R --slave -f $drh/drtime.R --args $flist $fhook $opt png
