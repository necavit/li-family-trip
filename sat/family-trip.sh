#!/bin/bash

# Family Trip problem automated solver script
# david.martinez.rodriguez@est.fib.upc.edu
#
# May 2015

# *** environment setting *** #
export PATH=$PATH:.

# *** variables *** #
symbolic=false #symbolic output
instance="foo" #instance_file
output="foo"   #output_file

# *** function declarations *** #
function usage {
	echo "usage: family-trip [-s output_file] instance_file.pl"
    echo "        -s turns on symbolic output (CNF form) to output_file and disables problem resolution"
    exit
}

# *** main script logic *** #
if [ $# -lt 1 ]; then
    echo "error: no arguments supplied"
    usage
fi

#command line arguments parsing
if [ "$1" == "-s" ]; then
	#symbolic output set to 1
	symbolic=true
	if [ -n "$2" ]; then
		output="$2"
		if [ -n "$3" ] && [ -f "$3" ]; then
			instance="$3"
		else
			echo "error: instance_file does not exist or is not specified"
			usage
		fi
	else
		echo "error: output_file not specified"
		usage
	fi
else
	#symbolic output set to 0
	if [ -n "$1" ] && [ -f "$1" ]; then
		instance="$1"
	else
		echo "error: instance_file does not exist or is not specified"
		usage
	fi
fi

#final solver filename:
solver_file="solver.pl"

#put the instance of the problem in a new file
echo "including instance $instance in $solver_file"
cat $instance > $solver_file

#append symbolic output to the solver file
echo "appending symbolic output to $solver_file"
if $symbolic ; then
	echo "symbolicOutput(1)." >> $solver_file
else
	echo "symbolicOutput(0)." >> $solver_file
fi

#append user made solver (the solver's logic)
echo "including solver logic (file: family-trip-solver.pl) to $solver_file"
cat family-trip-solver.pl >> $solver_file

#append display functions
echo "including display functions to $solver_file"
cat display-solution.pl >> $solver_file

#append main procedure to solver
echo "including main procedure to $solver_file"
cat main.pl >> $solver_file

solver_executable_file="solve"
#compile and create the executable solver file
echo "compilating the solver to an executable file $solver_executable_file"
swipl -O -g main --stand_alone=true -o $solver_executable_file -c $solver_file

#if symbolic output was set, execute and send output to output_file
if $symbolic ; then
	$solver_executable_file > $output 2> /dev/null
	echo "DONE executing solver!"
	echo "see $output to check clauses"
else #if symbolic output was not set, display the solution
	rm -f solution.txt
	$solver_executable_file > solution.txt 2> /dev/null
	echo "DONE executing solver!"
	cat solution.txt
fi