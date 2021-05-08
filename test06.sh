#!/bin/dash

# Line number exists but regex will not match any line in this sequence
SPEC=$(seq 17 21 | 2041 speed '3,/.4/d')
MINE=$(seq 17 21 | ./speed.pl '3,/.4/d')

# Should output
# 17
# 18

if [ "$SPEC" = "$MINE" ]
then
    echo "Passed";
    exit 1;
else
    echo "Failed";
    exit 0;
fi

# Outcome: Passed
