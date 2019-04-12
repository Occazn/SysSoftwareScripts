#!/bin/sh

# Michael Gleason
# COP 3402 Spring 2019
# Inspired by Sean Szumlanski

# ==================
# Lexer: test-lexer.sh
# ==================
# Run this script from the command line like so:
#
# 	bash test-lexer.sh
#
# This script must be in your project folder, and your "syllabus"
# and project folder must be in the same directory.
#
# For example, put "syllabus" and "project-<username>" on the desktop
# and make sure this script is in "project-<username>" folder

################################################################################
# User Specifications.
################################################################################

# Set to 1 (true) or 0 (false) as needed
using_binaries=0
include_grading_cases=0


################################################################################
# Shell check.
################################################################################

# Running this script with sh instead of bash can lead to false positives on the
# test cases. These checks ensure the script is not being run through the
# Bourne shell (or any shell other than bash).

if [ "$BASH" != "/bin/bash" ]; then
  echo ""
  echo " Please use bash to run this script, like so: bash test-lexer.sh"
  echo ""
  exit
fi

if [ -z "$BASH_VERSION" ]; then
  echo ""
  echo " Please use bash to run this script, like so: bash test-lexer.sh"
  echo ""
  exit
fi


################################################################################
# Initialization.
################################################################################

PASS_CNT=0
TOTAL_CASES=29
NUM_GRADING_CASES=49

# Add additional cases to total count
if [ $include_grading_cases == 1 ]; then
	TOTAL_CASES=`expr $TOTAL_CASES + $NUM_GRADING_CASES`
fi

# used for right-alignment
col=27


################################################################################
# Check that all required files are present.
################################################################################

if [ ! -f ../Makefile ]; then
	echo ""
	echo " Error: You seem to be in the wrong directory. Make sure the script"
	echo "        folder is in your \"project-<username>\" directory."
	echo "        (Aborting script)"
	echo ""
	exit 2
elif [ ! -d ../../syllabus ]; then
	echo ""
	echo " Error: You must place your \"project-<username>\" and syllabus directories"
	echo "        in the same directory before we can proceed. (Aborting script)"
	echo ""
	exit 2
elif [ ! -d ../../syllabus/project ]; then
	echo ""
	echo " Error: Your project folder is not in your syllabus folder. Why would"
	echo "        you move such sensitive things? SHAME! (Aborting script)"
	echo ""
	exit 2
elif [ ! -d ../../syllabus/project/tests ]; then
	echo ""
	echo " Error: Your tests folder is not in your project folder. Why would"
	echo "        you move such sensitive things? SHAME! (Aborting script)"
	echo ""
	exit 2
fi


################################################################################
# Compile and run test cases.
################################################################################

# Make sure latest edit to file is being used.
if [ $using_binaries == 0 ]; then
	cd .. && make > /dev/null 2> /dev/null
	make_res=$?
	cd scripts
	
	if [ $make_res != 0 ]; then
		echo ""
		echo " Error: make command was unsuccessful. Execute make for error message."
		echo "        (Aborting script)"
		echo ""
		exit 3
	fi
fi

# Test for every .pl0 extension in the current directory
run () {
	for i in $path/*.pl0;
	do
		[ -f "$i" ] || break

		# Extract filename from path and print
		filename=$(basename -- "${i%.*}")
		printf '  [Test Case] Checking %s...\t' "$filename" | expand -t $col

		# Attempt compilation and check for failure
		../compiler --lex $i > test.tokens 2> /dev/null
		compile_val=$?
		if [ $compile_val != 0 ]; then
			echo "fail (failed to compile)"
			continue
		fi

		# Remove extension from path
		sample_file="${i%.*}"

		# Run diff and capture return val
		diff test.tokens $sample_file.tokens > /dev/null
		diff_val=$?
		if [ $diff_val != 0 ]; then
			echo "fail (output mismatch)"
		else
			echo "PASS!"
			PASS_CNT=`expr $PASS_CNT + 1`
		fi
	done
	
	# remove test.tokens after running all testcases
	rm test.tokens
}

# Test the given testcases
echo ""
echo "============================================================================="
echo "Running given cases..."
echo "============================================================================="
echo ""

path=../../syllabus/project/tests
run

# Test cases used for grading if required
if [ $include_grading_cases == 1 ]; then
	echo ""
	echo "============================================================================="
	echo "Running grading cases..."
	echo "============================================================================="
	echo ""

	path=../../syllabus/project/tests/project1
	run
fi


################################################################################
# Report.
################################################################################

echo ""
echo "============================================================================="
echo "Final Report"
echo "============================================================================="

if [ $PASS_CNT -eq $TOTAL_CASES ]; then
	echo ""
	echo "  CONGRATULATIONS! You appear to be passing all the test cases provided"
	echo "  in the syllabus/project/tests folder!"
	echo ""
	echo "  DISCLAIMER: This script does not guarantee a 100% on your assignment"
	echo "  so please consider further testing and debugging."
	echo ""
	exit
else
	echo "                                 ."
	echo "                                \":\""
	echo "                              ___:____     |\"\\/\"|"
	echo "                            ,'        \`.    \\  /"
	echo "                            |  o        \\___/  |"
	echo "                          ~^~^~^~^~^~^~^~^~^~^~^~^~"
	echo ""
	echo "                                 (fail whale)"
	echo ""
	echo "  Looks like you're failing at least one testcase. Keep up the hard work"
	echo "  and refer to syllabus/project/overview.md for instructions."
	echo ""
	exit 1
fi
