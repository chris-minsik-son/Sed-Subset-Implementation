#!/bin/dash

# Inserting spaces between the digits (intention here is 11,21d)
SPEC=$(seq 1 30 | 2041 speed ' 1  1, 2  1  d  # comment')
MINE=$(seq 1 30 | ./speed.pl ' 1  1, 2  1  d  # comment')

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
