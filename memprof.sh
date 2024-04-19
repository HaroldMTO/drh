#!/bin/sh

drh=~/util/drh

usage()
{
	echo "Description:
	Produce plots for CPU memory usage from sampling files (simple dump of continously
running the Unix command free).

Usage:
	mem.sh PATTERN [-h]

Options:
	PATTERN: pattern for profiling files
	-h: print this help message and exit normally

Details:
	File names may follow '[pattern]...[host]' but can just follow '[pattern]...'
 as well. In the 1st case, [host] is an integer number, related to some machine index,
 for instance. PNG files produced are mem.[host].png in this 1st case or mem.png in the
 other case.
	Files may contain 2 more lines in addition to samples of comman 'free'. One line
should be for date and time, containing 'date:...' and the other should be for the
 sampling frequency, containing 'sample:...'. Date is the result of command 'date'
 as an example and the sample frequency should be a numeric value (.1, .5 or 2, etc).

Author:
	H Petithomme, Meteo France
"
}

set -e

if [ $# -eq 0 ] || echo " $*" | grep -qE ' -h\>'
then
	usage
	exit
fi

patt=""

while [ $# -ne 0 ]
do
	case $1 in
	-h)
		usage
		exit
		;;
	*) patt=$1;;
	esac

	shift
done

type R >/dev/null 2>&1 || module load -s intel R >/dev/null 2>&1

R --slave -f $drh/memprof.R --args $patt
