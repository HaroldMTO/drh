#!/bin/sh

drh=~/util/drh

usage()
{
	echo "Description:
	Produce plots for GPU and CPU memory usage and CPU activity from files in tmpmem

Usage:
	mem.sh JOBID [-v] [-h]

Options:
	JOBID: SLURM job id
	-v: verbose mode
	-h: print this help message and exit normally

Details:
	Files topmem.[JOBID].[NODE].txt and gpumem.[JOBID].[NODE].txt must exist in tmpmem. These files are produced by some memory profiling script.
	Graphic file produced is named mem.[NODE].png
"
}

set -e

if echo " $*" | grep -qE ' -h\>'
then
	usage
	exit
elif [ $# -eq 0 ] || ! echo $1 | grep -qE '^[0-9]+$'
then
	echo "usage: mem.sh JOBID
Try mem.sh -h for help" >&2
	exit 1
fi

type R >/dev/null 2>&1 || module load -s intel R >/dev/null 2>&1

for ftop in $(ls -1 tmpmem | grep -E "topmem\.$1.[[:alnum:]]+\.txt")
do
	node=$(echo $ftop | sed -re 's:.+\.(\w+)\.txt:\1:')
	fgpu=${ftop/topmem/gpumem}

	R --slave -f $drh/mem.R --args $node tmpmem/$ftop tmpmem/$fgpu
done
