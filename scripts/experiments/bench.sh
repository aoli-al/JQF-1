#!/bin/bash

set -e

if [ $# -lt 6 ]; then
  echo "Usage: $0 <NAME> <TEST_CLASS> <IDX> <TIME> <DICT> <SEEDS>"
  exit 1
fi

pushd `dirname $0` > /dev/null
SCRIPT_DIR=$( dirname "$0" )
popd > /dev/null

JQF_DIR="$SCRIPT_DIR/../.."
JQF_EI="$JQF_DIR/bin/jqf-ei"
JQF_ZEST="$JQF_DIR/bin/jqf-zest"
NAME=$1
TEST_CLASS="edu.berkeley.cs.jqf.examples.$2"
IDX=$3
TIME=$4
DICT="$JQF_DIR/examples/target/test-classes/dictionaries/$5"
SEEDS="$JQF_DIR/examples/target/seeds/$6"
SEEDS_DIR=$(dirname "$SEEDS")

e=$IDX

EI_OUT_DIR="$NAME-ei-results-$e"
EI_FAST_OUT_DIR="$NAME-ei-fast-results-$e"
ZEST_OUT_DIR="$NAME-zest-results-$e"
ZEST_FAST_OUT_DIR="$NAME-zest-fast-results-$e"

if [ -d "$JQF_OUT_DIR" ]; then
  echo "Error! There is already a directory by the name of $EI_OUT_DIR"
  exit 3
fi

# Do not let GC mess with fuzzing
export JVM_OPTS="$JVM_OPTS -XX:-UseGCOverheadLimit"


SNAME="$NAME-$e"

screen -S "$SNAME" -dm -t ei_$e
screen -S "$SNAME" -X screen -t zest_$e
screen -S "$SNAME" -p ei_$e -X stuff "timeout $TIME $JQF_EI -c \$($JQF_DIR/scripts/examples_classpath.sh) $TEST_CLASS testWithGenerator $EI_OUT_DIR^M"
screen -S "$SNAME" -p zest_$e -X stuff "timeout $TIME $JQF_ZEST -c \$($JQF_DIR/scripts/examples_classpath.sh) $TEST_CLASS testWithGenerator $ZEST_OUT_DIR^M"

FAST_ENV="\"$JVM_OPTS -DuseFastNonCollidingCoverageInstrumentation=true\""
screen -S "$SNAME" -X screen -t ei_fast_$e
screen -S "$SNAME" -X screen -t zest_fast_$e
screen -S "$SNAME" -p ei_fast_$e -X stuff "JVM_OPTS=$FAST_ENV timeout $TIME $JQF_EI -c \$($JQF_DIR/scripts/examples_classpath.sh) -D-DuseFastNonCollidingCoverageInstrumentation=true $TEST_CLASS testWithGenerator $EI_FAST_OUT_DIR^M"
screen -S "$SNAME" -p zest_fast_$e -X stuff "JVM_OPTS=$FAST_ENV timeout $TIME $JQF_ZEST -c \$($JQF_DIR/scripts/examples_classpath.sh) $TEST_CLASS testWithGenerator $ZEST_FAST_OUT_DIR^M"
