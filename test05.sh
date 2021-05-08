#!/bin/dash

# Quit on a line that does not exist (i.e. doesn't match the regex)
SPEC=$(seq 10 15 | 2041 speed '/.7/q')
MINE=$(seq 10 15 | ./speed.pl '/.7/q')

# Should output
# 10
# 11
# 12
# 13
# 14
# 15

if [ "$SPEC" = "$MINE" ]
then
    echo "Passed";
    exit 1;
else
    echo "Failed";
    exit 0;
fi

# Outcome: Passed
