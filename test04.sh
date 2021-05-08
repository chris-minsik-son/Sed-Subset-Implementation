#!/bin/dash

# Insert the -n option after the command argument
SPEC=$(seq 1 5 | 2041 speed '3p' -n)
MINE=$(seq 1 5 | ./speed.pl '3p' -n)

# Should output
# 3

if [ "$SPEC" = "$MINE" ]
then
    echo "Passed";
    exit 1;
else
    echo "Failed";
    exit 0;
fi

# Outcome: Failed
