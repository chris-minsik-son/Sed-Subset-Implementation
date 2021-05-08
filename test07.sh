#!/bin/dash

# Regex exists but line number does not exist in this sequence
SPEC=$(seq 2 21 | 2041 speed '/^1/,23d')
MINE=$(seq 2 21 | ./speed.pl '/^1/,23d')

# Should output
# 2
# 3
# 4
# 5
# 6
# 7
# 8
# 9

if [ "$SPEC" = "$MINE" ]
then
    echo "Passed";
    exit 1;
else
    echo "Failed";
    exit 0;
fi

# Outcome: Passed
