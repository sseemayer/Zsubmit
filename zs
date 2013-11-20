#!/bin/zsh
emulate -RL zsh
setopt extendedglob

local exename=$0
local pattern repl_name repl_args repl_output files
local job_name job_arg job_output qsub_args

local dry_run=''
local verbose=''

typeset -A job_names job_args job_outputs

function usage {
	print "Usage: $exename [options] file_glob name_pattern command_name [command_arg_pattern1] [...]" >&2
	print ""
}

function help {
	usage
	print "Options:"
	print "\t-q ARGUMENT\tSpecify qsub argument"
	print "\t-o OUTFILE \tSpecify qsub output file pattern"
	print "\t-d         \tDry run (only show qsub command, don't run it)"
	print "\t-v         \tVerbose (show qsub command before running it)"
	print "\t-h         \tDisplay this help and exit"

}

job_script=~/q
qsub='qsub'
za='za'

qsub_args=()
while getopts ":q:o:dvh" opt; do
	case $opt in
		q)
			qsub_args+=($OPTARG)
			;;
		o)
			repl_output=$OPTARG
			;;
		d)
			dry_run='echo'
			;;
		v)
			verbose='-v'
			;;
		h)
			help
			exit 0
			;;
		\?)
			print "Unknown argument: -$OPTARG"
			print ""
			usage
			exit 1
			;;
	esac
done

if [[ $(($# - $OPTIND)) -lt 2 ]]; then
	usage
	exit 1
fi

shift $((OPTIND-1))

pattern=$1
repl_name=$2
shift 2

# if no output pattern is specified, generate output pattern from job name
[[ -z "$repl_output" ]] && repl_output=${repl_name}.log

# use za for handling pattern substitution
$za $verbose $pattern $dry_run $qsub $qsub_args -N $repl_name -j y -o $repl_output $job_script $@
