#!/bin/dash

# Delete a line that doesn't exist
SPEC=$(seq 1 5 | 2041 speed '7d')
MINE=$(seq 1 5 | ./speed.pl '7d')

# Should output
# 1
# 2
# 3
# 4
# 5

if [ "$SPEC" = "$MINE" ]
then
    echo "Passed";
    exit 1;
else
    echo "Failed";
    exit 0;
fi

# Outcome: Passed
