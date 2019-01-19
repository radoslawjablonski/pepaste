#! /usr/bin/perl -w

use 5.14.0; # for 'say'
use strict;
use Getopt::Long qw(:config bundling); # for case sensitive
use Pod::Usage qw(pod2usage);;
use Carp; # for croak()

use constant PEPASTE_VERSION_STR => "Pepaste version: 0.2";

my %params = ('num-words' => '',
			  'split-delim' => ' ',
			  'match-word-regex' => '',
			  'match-line-regex' => '',
			  'exclude-word-regex' => '',
			  'exclude-line-regex' => '',
			  'verbose' => 0,
			  'end-line-string' => '',
			  'output-word-separator' => ' ',
			  'columns-selected' => '',
			  'out-of-bounds-str' => '',
			  'help' => 0,
			  'usage' => 0,
			  'version' => 0);

GetOptions('num-words|n=i' => \$params{'num-words'},
		   'split-delim|d=s' => \$params{'split-delim'},
		   'match-word-regex|w=s' =>  \$params{'match-word-regex'},
		   'exclude-word-regex|W=s' => \$params{'exclude-word-regex'},
		   'match-line-regex|l=s' =>  \$params{'match-line-regex'},
		   'exclude-line-regex|L=s' =>  \$params{'exclude-line-regex'},
		   'verbose|v' => \$params{'verbose'},
		   'end-line-string|e=s' => \$params{'end-line-string'},
		   'output-word-separator|s=s' => \$params{'output-word-separator'},
		   'columns-selected|c=s' => \$params{'columns-selected'},
		   'out-of-bounds-str|o=s' => \$params{'out-of-bounds-str'},
		   'help|h' => \$params{'help'},
		   'usage' => \$params{'usage'},
		   'version' => \$params{'version'}
	   )
	or pod2usage(-verbose => 0);
;

sub say_d {
	# printing all params if debug is enabled
	if ($params{'verbose'}) {
		say @_;
	}
}

sub init_default_options {
	# it is nice to initialize n to size of columns to print if '-c' option
	# is used so user don't have to type -n manually
	if (!$params{'num-words'}) {
		if ($params{'columns-selected'}) {
			my @columns_idx_arr = split(',', $params{'columns-selected'});
			# setting num-columns to size only if size > 1, otherwise print
			# everything in one line to be consistent with default no-'n'
			# behavior
			if (@columns_idx_arr > 1) {
				$params{'num-words'} = @columns_idx_arr;
				say_d "Setting value to num-words based on 'columns-selected' param to "
					.scalar @columns_idx_arr;
			}
		}
	}

	# if there is something left in @ARGV, then taking first thing as
	# a word-regex (BUT only if regex not set using options)
	if (@ARGV) {
		if (@ARGV == 1 && !$params{'match-word-regex'}) {
			say_d "Setting match-word-regex to $ARGV[0]";
			$params{'match-word-regex'} = $ARGV[0];
		} else {
			say "Warning: multiple non-parsed options ignored: @ARGV";
		}
	}
}

{
	# use for tracking if newline is needed on end of the program
	my $was_flushed = 1;

	sub print_word {
		croak "Wrong number of arguments: ".@_ if @_ != 3;

		my $word = shift;
		my $max_n_words = shift;
		my $word_counter = shift;

		if (!$was_flushed) {
			# it means that other word was already printed in that
			# line, we have to add delimiter char before
			print $params{'output-word-separator'};
		}

		print $word;

		# if $max_n_words not defined, then everything will be always
		# printed in single line
		if ($max_n_words && $word_counter % $max_n_words == 0) {
			# printing end of line
			print "$params{'end-line-string'}\n";
			$was_flushed = 1;
		} else {
			$was_flushed = 0;
		}
	}

	sub flush_if_needed {
		if (!$was_flushed) {
			print "$params{'end-line-string'}\n";
		}
	}
}

## $str, $regex
sub check_match {
	croak("Wrong number of arguments: ".@_) if @_ != 2;

	my $str = shift;
	my $regex = shift;

	if ($str eq '') {
		say_d "Skipping match for string $str because regex empty with 0 exit..";
		return 0;
	}

	# Applying word regex if passed as a param
	if ($str =~ m/$regex/) {
		return 1;
	} else {
		return 0;
	}
}

sub validate_columns_str {
	my $columns_str = shift;

	# we are looking for digit number that is at the end of series
	# 'digit,' (digit colon) sequence. Whitespace after colon are also
	# acceptable
	if ($columns_str !~ /^(\d+\,\s?)*(\d+)+$/) {
		die "Wrong columns array passed: '".$columns_str."'";
	}

}

sub print_version {
	say PEPASTE_VERSION_STR;
	exit(0);
}

### Start ####
if ($params{'help'}) {
	pod2usage(-exitval => 0,
			  -verbose => 0,
			  -message => "Use '--usage' option for more detailed help information\n");
}

if ($params{'usage'}) {
	pod2usage(-exitval => 0,
			  -verbose => 2,
			  -noperldoc => 1,
		  -message => PEPASTE_VERSION_STR);
}

print_version() if $params{'version'};

init_default_options(); # smart initializing some vars based on params

say_d 'Using column size: '.$params{'num-words'};
say_d 'Using word regex: '.$params{'match-word-regex'};
say_d 'Using exclude word regex: '.$params{'exclude-word-regex'};
say_d "End line string: $params{'end-line-string'}";

my $wcount = 1; # word counter
while (my $line = <STDIN>) {
	chomp($line);

	# if match-line-regex is passed, then we are filtering input LINES
	# only matched lines will be handled
	if ($params{'match-line-regex'} &&
			!check_match($line, $params{'match-line-regex'})) {
		say_d "Skipping $line because of 'match-line-regex'";
		next;
	}

	# also we have exclude line regex - we are SKIPPING lines that
	# are matched by exclude-line-regex
	if ($params{'exclude-line-regex'} &&
			check_match($line, $params{'exclude-line-regex'})) {
		say_d "Skipping $line because of 'exclude-line-regex'";
		next;
	}

	my @words_in_line = split($params{'split-delim'}, $line);
	my @columns_idx_arr;
	# if user has given columns, then using it now..
	if ($params{'columns-selected'}) {
		validate_columns_str($params{'columns-selected'});
		@columns_idx_arr = split(',', $params{'columns-selected'});

		# substracting '1' from all indexes to make columns selection
		# more user friendly - user will pass columns starting with '1'
		$_-- foreach @columns_idx_arr;
	} else {
		# traditional approach, all columns will be visible
		@columns_idx_arr = (0 .. $#words_in_line);
	}

	# yeah, I know it would be better to use it directly in foreach
	# fashion but not if I want to have indexes of particular column
	for my $col_idx (@columns_idx_arr) {
		# It may occur that user will pass columns that not always will be
		# available. If we won't do nothing, then output will be messed with
		# not very meaningfull errors
		my $word;

		if ($col_idx > $#words_in_line) {
			say_d "In line <$line> caught out of bounds index ".($col_idx + 1).
				" Printing out-of-bounds-str: <$params{'out-of-bounds-str'}>";
			$word = $params{'out-of-bounds-str'};
		} else {
			$word = $words_in_line[$col_idx];
		}

		# skipping if word does NOT match-word-regex
		if ($params{'match-word-regex'} &&
				!check_match($word, $params{'match-word-regex'})) {
			say_d "Skipping $word because of match-word-regex";
			next;
		}

		# skipping if word matches exclude-word-regex
		if ($params{'exclude-word-regex'} &&
				check_match($word, $params{'exclude-word-regex'})) {
			say_d "Skipping $word because of exclude-word-regex";
			next;
		}

		print_word($word, $params{'num-words'}, $wcount);

		$wcount++;
	}
}

# flushing on the end - it causes problems on some shells
# if not flushed..
flush_if_needed;

=head1 SYNOPSIS

$ <INPUT_STREAM>|pepaste [-vh ] [ --num-words|-n NUM ]
[ --columns-selected|-c ]
[ --split-delim|-d ' ' ]
[ --match-word-regex|-w 'regex_match(without //)' ]
[ --exclude-word-regex|-W 'no_match_regex(without //)']
[ --exclude-line-regex|-L 'no_match_regex(without //)']
[ --match-line-regex|-l 'regex_match(without //)' ]
[ --end-line-string|-e '' ]
[ --out-of-bounds-str|-o '']
[ --output-word-separator|-s ' ' ]
[ --version ]

=head1 OPTIONS

=over 8

=item B<--columns-selected '1,2 .. N'> or B<-c '1,2..N'>

string representing list of columns from input stream that will be displayed, rest
of the content will be ignored

=over

=item dpkg -l|pepaste -c "1,2"

=back

will display only content from column '1' and '2'

=item B<--num-words N> or B<-n N>

number of words per line that will be generated in output stream. Default '0' means that everything will be printed in one single line.

=item B<--output-word-separator ' '> or B<-s ' '>

set separator that is used after every printed word. At default one whitespace is used (' '). Example:

=over

=item $ echo a b c d e f|pepaste -n 3 -s , 

=item a,b,c

=item d,e,f

=back

=item B<--split-delim ' '> or B<-d ' '>

delimiter of words in line in INPUT stream - used when each input line consists of more than one field

=item B<--match-word-regex 'regex_match'> or B<-w 'regex_match'>

print only WORDS that matching given regex e.g.: -w 'a' will print only words containing 'a' and rest will be filtered out

=over

=item NOTE: passing regex in form '/match/' is not needed because match string
is already enclosed with '//' in perl code in order to save typing in command line.
In other words passing -w '^a' will be rolled into '/^a/' in perl code

=back

=item B<--exclude-word 'non_match_regex'> or B<-W 'non_match_regex'>

Reversed version of -w parameter - skip words if match exists

=over

=item NOTE: passing regex in form '/non_regex_match/' is not needed because match string
is already enclosed with '//' in perl code in order to save typing in command line.
In other words passing -M '^a' will be rolled into '/^a/' in perl code

=back

=item B<--match-line-regex 'regex_match'> or B<-l 'regex_match'>

print only LINES that matching given regex e.g.: -l 'a' will print only lines containing 'a' and rest will be filtered out

=over

=item NOTE: passing regex in form '/match/' is not needed because match string
is already enclosed with '//' in perl code in order to save typing in command line.
In other lines passing -l '^a' will be rolled into '/^a/' in perl code

=back

=item B<--exclude-line-regex 'regex_match'> or B<-L 'regex_match'>

this is opposite of '-l' option. Discard LINES that matching given regex e.g.: -L '^a' will throw away lines are beginning with 'a' letter and those lines won't be included in output stream..

=over

=item NOTE: passing regex in form '/match/' is not needed because match string
is already enclosed with '//' in perl code in order to save typing in command line.
In other lines passing -L '^a' will be rolled into '/^a/' in perl code

=back

=item B<--end-line-string ''> or B<-e ''>

set string that is additionally printed on end of every line, just before newline marker. Here is the example:

=over

=item $ echo a b c d e f|pepaste -n 3 -e '\'

=item a,b,c\

=item d,e,f\

=back

=item B<--out-of-bounds-str> or B<-o>

set string that will be printed when no column with given index
will be found. It is used only when '-c' option has been passed
by user and some line occurred with less elements than expected - by
default empty string is printed out in that place but it can be
customized using this parameter.

=item B<--verbose> or B<-v>

prints additional debug information

=item B<--help> or B<-h>

short help information

=item B<--version>

Print version information

=back
