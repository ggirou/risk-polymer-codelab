#!/bin/bash -e

STEPS=(s1_basics s2_classes s3_element s4_template s5_board s6_alltogether)
MAX_PROCS=${MAX_PROCS:=1}

# $0..N-1 pub parameters to run
# $N step directory
function pub_cmd() {
	pushd $PWD/${@: -1}; pub ${@: 1 : $(($#-1))}; popd
}

# $1 test script
# $2 steps to test
function run_test() {
	dart $PWD/$2/test/$1.dart
}

# $1 steps to build
function build() {
	pub_cmd build $1
	mv $PWD/$1/build/web $PWD/build/$1
}

function log() { echo -e "\n##########################################\n# $*\n##########################################\n"; }
# $1 steps to output
function foreach() { printf "%s\n" $*; }
# $1 command to run
function execute() { xargs -l1 -i bash -c "log $* {}; $* {}"; }
# $1 command to run in parallel
function execute_p() { log $*; xargs -l1 -i -P $MAX_PROCS bash -c "$* {}"; }

# Needed for xargs
export -f log pub_cmd run_test build

rm -r -f $PWD/build
mkdir -p $PWD/build

pub_cmd get "${STEPS[0]}"
foreach ${STEPS[@]:1} | execute_p pub_cmd get
foreach ${STEPS[@]:1} | execute run_test "s2_classes_test"
foreach ${STEPS[@]:3:4} ${STEPS[9]} | execute_p build

