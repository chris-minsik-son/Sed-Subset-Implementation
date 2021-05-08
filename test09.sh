#!/bin/dash

# Comment before the comma
SPEC=$(seq 1 30 | 2041 speed ' 11 #comment   , 21d')
MINE=$(seq 1 30 | ./speed.pl ' 11 #comment   , 21d')

# Should output
# speed: command line: invalid command

if [ "$SPEC" = "$MINE" ]
then
    echo "Passed";
    exit 1;
else
    echo "Failed";
    exit 0;
fi

# Outcome: Passed
