#!/bin/dash

# Insert additional g characters for substitute command
SPEC=$(seq 1 20 | 2041 speed 's/1/X/gg')
MINE=$(seq 1 20 | ./speed.pl 's/1/X/gg')

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

# Outcome: Failed
