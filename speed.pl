#!/usr/bin/perl -w

# Read in arguments and save to INPUT (and -n if provided)
if (@ARGV == 1) {
    $INPUT = $ARGV[0];
} elsif (@ARGV == 2) {
    $N_USED = $ARGV[0];
    $INPUT = $ARGV[1];
}

# If our command contains comma, this will specify the ranges
if (defined($INPUT) == 1 && $INPUT =~ /,/) {
    @RANGES = split(',', $INPUT);
    $START = $RANGES[0];
    $START =~ s/\s//g;
    $END = $RANGES[1];
    if ($END =~ /\s/ || $END =~ /#/) {
        $END =~ s/\s//g;
        $END =~ /(.*[pqd])#.*/;
        $END = $1;
    }
    
}

# If we have a range of lines the command applies to
if (@RANGES && defined($START) == 1 && defined($END) == 1) {
    # START should either be a line number or regex
    if ($START =~ /^([\d]+)$/) {
        $STARTNUM = $1;
    } elsif ($START =~ /^\/([^\/]+)\/$/) {
        $STARTREGEX = $1;
    } else {
        print "speed: command line: invalid command\n";
        exit 1;
    }

    # END should either be a line number or regex
    # For now, only taking print and delete commands
    if ($END =~ /^([\d]+)([pd])$/) {
        $ENDNUM = $1;
        $COMMAND = $2;
    } elsif ($END =~ /^\/([^\/]+)\/([pd])$/) {
        $ENDREGEX = $1;
        $COMMAND = $2;
    } else {
        print "speed: command line: invalid command\n";
        exit 1;
    }
}

# print "Printing values: $STARTNUM and $STARTREGEX and $ENDNUM and $ENDREGEX and $COMMAND\n";

# The following (2) if statements are only working when the comma case is satisfied
if (defined($COMMAND) == 1 && $COMMAND =~ /^p$/) {
    my $COUNT = 0;
    my $MATCHED = 0;
    my $DONE = 0;
    # Read each line from STDIN
    while (my $LINE = <STDIN>) {
        # Update line number each iteration
        $COUNT++;
        # Print lines twice when we match the start line number and stop when we match the end line number
        if (defined($STARTNUM) == 1 && defined($ENDNUM) == 1) {
            if ($COUNT >= $STARTNUM && $COUNT <= $ENDNUM) {
                print "$LINE";
            }
            print "$LINE";
        
        # Print lines twice when we match the start line number and stop when we match the end regex
        } elsif (defined($STARTNUM) == 1 && defined($ENDREGEX) == 1) {
            print "$LINE";
            if ($COUNT == $STARTNUM) {
                $MATCHED = 1;
            # Set MATCHED back to 0 if we match the end regex
            } elsif ($LINE =~ /$ENDREGEX/) {
                $MATCHED = 0;
            }

            # Print line again if we have already matched the start line number
            if ($MATCHED == 1) {
                print "$LINE";
            }

        # Print lines twice when we match the start regex and stop when we match the end line number
        } elsif (defined($STARTREGEX) == 1 && defined($ENDNUM) == 1) {
            print "$LINE";
            
            # After ending regex match, all other lines matching starting regex are printed again
            if ($DONE == 1) {
                if ($LINE =~ /$STARTREGEX/) {
                    print "$LINE";
                }
                next;
            }
            
            # This is before the matching of ending regex:
            if ($LINE =~ /$STARTREGEX/) {
                $MATCHED = 1;
            }

            if ($COUNT == $ENDNUM) {
                $DONE = 1;
            }

            if ($MATCHED == 1) {
                print "$LINE";
            }
            

        # Print lines twice when we match the start regex and stop when we match the end regex
        } elsif (defined($STARTREGEX) == 1 && defined($ENDREGEX) == 1) {
            print "$LINE";
            if ($LINE =~ /$STARTREGEX/) {
                $MATCHED = 1;
            
            # Set MATCHED back to 0 if we match the end line number
            } elsif ($LINE =~ /$ENDREGEX/) {
                $MATCHED = 0;
            }

            # Print line again if we have already matched the start regex
            if ($MATCHED == 1) {
                print "$LINE";
            }
        }
    
    }
    exit 1;
}

if (defined($COMMAND) == 1 && $COMMAND =~ /^d$/) {
    my $COUNT = 0;
    my $MATCHED = 0;
    my $DONE = 0;

    # Read each line from STDIN
    while (my $LINE = <STDIN>) {
        $COUNT++;

        # Don't print lines when we match between start and end line number
        if (defined($STARTNUM) == 1 && defined($ENDNUM) == 1) {
            if ($COUNT < $STARTNUM || $COUNT > $ENDNUM) {
                print "$LINE";
            }
        
        } elsif (defined($STARTNUM) == 1 && defined($ENDREGEX) == 1) {
            # We matched the end regex so print all lines afterwards
            if ($DONE == 1) {
                print "$LINE";
                next;
            }

            if ($COUNT == $STARTNUM) {
                $MATCHED = 1;
            } elsif ($LINE =~ /$ENDREGEX/ && $COUNT != 1) {
                $DONE = 1;
            }
            
            if ($MATCHED == 0) {
                print "$LINE";
            }

        } elsif (defined($STARTREGEX) == 1 && defined($ENDNUM) == 1) {
            if ($LINE =~ /$STARTREGEX/) {
                $MATCHED = 1;
            }
            
            if ($COUNT == $ENDNUM && $MATCHED) {
                $DONE = 1;
                $MATCHED = 0;
                next;
            }
            
            if ($MATCHED == 0 && $LINE !~ /$STARTREGEX/) {
                print "$LINE";
            }

        } elsif (defined($STARTREGEX) == 1 && defined($ENDREGEX) == 1) {
            if ($LINE =~ /$STARTREGEX/) {
                $MATCHED = 1;
            }

            if ($MATCHED != 1 && $LINE !~ /$STARTREGEX/) {
                print "$LINE";
            }

            if ($LINE =~ /$ENDREGEX/ && $MATCHED == 1) {
                $MATCHED = 0;
            }
            
            
        }
    
    }
    exit 1;
}

# Reads input from argument and retrieves regex, command etc
# Returns a hash table containing these values
sub readinput {
    $INPUT = $_[0];
    if (defined($INPUT) == 1 && $INPUT =~ /.*s(.).*/) {
        $DELIMITER = $1;
    }

    my %TABLE;

    # e.g. ./speed.pl '/1.1/p/'
    if (defined($INPUT) == 1 && $INPUT =~ /^\/([^\/]+)\/([qpd])$/) {
        $REGEX = $1;
        $COMMAND = $2;

        $TABLE{REGEX} = $REGEX;
        $TABLE{COMMAND} = $COMMAND;
        # print "$REGEX and $COMMAND\n";
        # exit;

    # e.g. ./speed.pl '5d'
    } elsif (defined($INPUT) == 1 && $INPUT =~ /^([\d\$]+)([qpd])$/) {
        $LINENUM = $1;
        $COMMAND = $2;

        $TABLE{LINENUM} = $LINENUM;
        $TABLE{COMMAND} = $COMMAND;
        # print "$LINENUM and $COMMAND\n";
        # exit;

    # e.g. 
    } elsif (defined($DELIMITER) == 1 && $INPUT =~ /(^[\d+]?s)[$DELIMITER](.*)[$DELIMITER](.*)[$DELIMITER](g?)/) {
        $COMMAND = $1;
        $REGEX = $2;
        $REPLACE = $3;
        $G_USED = $4;

        $TABLE{COMMAND} = $COMMAND;
        $TABLE{REGEX} = $REGEX;
        $TABLE{REPLACE} = $REPLACE;
        $TABLE{G_USED} = $G_USED;
        # print "$COMMAND and $REGEX and $REPLACE and $G_USED\n";
        # exit;
    } elsif (defined($DELIMITER) == 1 && $INPUT =~ /[$DELIMITER](.*)[$DELIMITER](s)[$DELIMITER](.*)[$DELIMITER](.*)[$DELIMITER](g?)$/) {
        $ADDRESS = $1;
        $COMMAND = $2;
        $REGEX = $3;
        $REPLACE = $4;
        $G_USED = $5;

        $TABLE{ADDRESS} = $ADDRESS;
        $TABLE{COMMAND} = $COMMAND;
        $TABLE{REGEX} = $REGEX;
        $TABLE{REPLACE} = $REPLACE;
        $TABLE{G_USED} = $G_USED;

        # print "$ADDRESS and $COMMAND and $REGEX and $REPLACE and $G_USED\n";
        # exit;
    } elsif (defined($INPUT) == 1 && $INPUT =~ /^(\w)$/) {
        $COMMAND = $1;

        $TABLE{COMMAND} = $COMMAND;
        # print "$COMMAND\n";
        # exit;
    } else {
        print "speed: command line: invalid command\n";
        exit 1;
    }

    return %TABLE;

}

# Retrieval of hash containing regex, line number, command, etc
my %TABLE = readinput($INPUT);

# Sub function for quit
sub q {
    my $COUNT = 0;
    $LINENUM = $_[0];
    $REGEX = $_[1];
    
    # Check if line number is defined either as an integer or address
    if (defined($LINENUM) == 1 && $LINENUM =~ /\d+/) {
        while (my $LINE = <STDIN>) {
            $COUNT++;
            print "$LINE";
            if ($COUNT == $LINENUM) {
                exit 0;
            }
        }
        exit 0;
    
    # $ was used as an address, print all lines then quit
    } elsif (defined($LINENUM) == 1 && $LINENUM =~ /\$/) {
        while (my $LINE = <STDIN>) {
            print "$LINE";
        }
        exit 0;

    # Otherwise print until we match the regex
    } elsif (defined($REGEX) == 1) {
        while (my $LINE = <STDIN>) {
            print "$LINE";
            if ($LINE =~ /$REGEX/) {
                exit 0;
            }
        }
        exit 0;
    }
}

# Sub function for print
sub p {
    my $COUNT = 0;
    $LINENUM = $_[0];
    $REGEX = $_[1];
    $N_USED = $_[2];
    
    if (defined($LINENUM) == 0 && defined($REGEX) == 0) {
        while (my $LINE = <STDIN>) {
            print "$LINE";
            if (defined($N_USED) == 0 || $N_USED !~ /-n/) {
                print "$LINE";
            }
        }
        exit 0;
    }

    # Check if line number is defined from input
    if (defined($LINENUM) == 1 && $LINENUM =~ /\d+/) {
        while (my $LINE = <STDIN>) {
            $COUNT++;
            if (defined($N_USED) == 0 || $N_USED !~ /-n/) {
                print "$LINE";
            }
            if ($COUNT == $LINENUM) {
                print "$LINE";
            }
        }
        exit 0;
    } elsif (defined($LINENUM) == 1 && $LINENUM =~ /^\$$/) {
        while (my $LINE = <STDIN>) {
            $RECENT = $LINE;
            if (defined($N_USED) == 0 || $N_USED !~ /-n/) {
                print "$LINE";
            }
        }
        print "$RECENT";
        exit 0;


    # Otherwise print each line and an additional line for a regex match
    } elsif (defined($REGEX) == 1) {
        while (my $LINE = <STDIN>) {
            if (defined($N_USED) == 0 || $N_USED !~ /-n/) {
                print "$LINE";
            }
            if ($LINE =~ /$REGEX/) {
                print "$LINE";
            }
        }
        exit 0;
    }
}

# Sub function for delete
sub d {
    my $COUNT = 0;
    $LINENUM = $_[0];
    $REGEX = $_[1];
    $N_USED = $_[2];
    
    if (defined($N_USED) == 1 && $N_USED =~ /-n/) {
        exit 0;
    }

    if (defined($LINENUM) == 1) {
        if ($LINENUM =~ /^\d+$/) {
            while (my $LINE = <STDIN>) {
                $COUNT++;
                if ($COUNT != $LINENUM) {
                    print "$LINE";
                }
            }
            exit 0;
        
        # If the $ sign was given, print all lines except last line
        } elsif ($LINENUM =~ /^\$$/) {
            while (my $LINE = <STDIN>) {
                if (defined($RECENT) == 1) {
                    print "$RECENT";
                }
                $RECENT = $LINE;
            }
            exit 0;
        }
        
    } elsif (defined($REGEX) == 1) {
        while (my $LINE = <STDIN>) {
            if ($LINE !~ /$REGEX/) {
                print "$LINE";
            }
        }
        exit 0;
    }
}

# Sub function for substitute
sub s {
    my $COUNT = 0;
    $ADDRESS = $_[0];
    $G_USED = $_[1];
    $REGEX = $_[2];
    $REPLACE = $_[3];
    $LINENUM = $_[4];
    $COMMAND = $_[5];

    # Check if address is defined from input
    if (defined($ADDRESS) == 1) {
        while (my $LINE = <STDIN>) {
            if ($G_USED =~ /g/) {
                if ($LINE =~ /$ADDRESS/) {
                    $LINE =~ s/$REGEX/$REPLACE/g;
                    print "$LINE";
                } else {
                    print "$LINE";
                }
            } else {
                if ($LINE =~ /$ADDRESS/) {
                    $LINE =~ s/$REGEX/$REPLACE/;
                    print "$LINE";
                } else {
                    print "$LINE";
                }
            }
        }
    } else {
        my $LINENUM = $COMMAND;
        $LINENUM =~ s/s//;
        
        while (my $LINE = <STDIN>) {
            $COUNT++;
            if ($LINENUM =~ /\d+/) {
                if ($COUNT == $LINENUM) {
                    if ($LINE =~ /$REGEX/ && $G_USED =~ /g/) {
                        $LINE =~ s/$REGEX/$REPLACE/g;
                    } elsif ($LINE =~ /$REGEX/ && $G_USED !~ /g/) {
                        $LINE =~ s/$REGEX/$REPLACE/;
                    }
                    print "$LINE";
                } else {
                    print "$LINE";
                }
            } else {
                if ($LINE =~ /$REGEX/ && $G_USED =~ /g/) {
                    $LINE =~ s/$REGEX/$REPLACE/g;
                } elsif ($LINE =~ /$REGEX/ && $G_USED !~ /g/) {
                    $LINE =~ s/$REGEX/$REPLACE/;
                }
                print "$LINE";
            }
        }
    }
}

# Execute sub functions based on particular commands
if ($TABLE{COMMAND} =~ /q/) {
    &q($TABLE{LINENUM}, $TABLE{REGEX});
} elsif ($TABLE{COMMAND} =~ /p/) {
    &p($TABLE{LINENUM}, $TABLE{REGEX}, $N_USED);
} elsif ($TABLE{COMMAND} =~ /d/) {
    &d($TABLE{LINENUM}, $TABLE{REGEX}, $N_USED);
} elsif ($TABLE{COMMAND} =~ /s/) {
    &s($TABLE{ADDRESS}, $TABLE{G_USED}, $TABLE{REGEX}, $TABLE{REPLACE}, $TABLE{LINENUM}, $TABLE{COMMAND});
}

exit;