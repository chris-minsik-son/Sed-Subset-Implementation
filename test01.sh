#!/bin/dash

# Print a line number that doesn't exist
SPEC=$(seq 1 10 | 2041 speed '11p')
MINE=$(seq 1 10 | ./speed.pl '11p')

# Should output
# 1
# 2
# 3
# 4
# 5
# 6
# 7
# 8
# 9
# 10

if [ "$SPEC" = "$MINE" ]
then
    echo "Passed";
    exit 1;
else
    echo "Failed";
    exit 0;
fi

# Outcome: Passed
