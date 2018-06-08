#! /usr/bin/perl -w

use 5.14.0; # for 'say'
use strict;
use Getopt::Long qw(:config bundling); # for case sensitive
use Pod::Usage qw(pod2usage);;
use Carp; # for croak()

my %params = ('num-words' => 1,
			  'split-delim' => ' ',
			  'match-word-regex' => '',
			  'exclude-word-regex' => '',
			  'verbose' => 0,
			  'end-line-prefix' => '',
			  'output-word-separator' => ' ',
			  'columns-selected' => '',
			  'help' => 0);

GetOptions('num-words|n=i' => \$params{'num-words'},
		   'split-delim|d=s' => \$params{'split-delim'},
		   'match-word-regex|m=s' =>  \$params{'match-word-regex'},
		   'exclude-word-regex|M=s' => \$params{'exclude-word-regex'},
		   'verbose|v' => \$params{'verbose'},
		   'end-line-prefix|e=s' => \$params{'end-line-prefix'},
		   'output-word-separator|w=s' => \$params{'output-word-separator'},
		   'columns-selected|c=s' => \$params{'columns-selected'},
		   'help|h' => \$params{'help'}
	   )
	or pod2usage(-verbose => 0);
;

# TODO: handle last \ in line

sub say_d {
	# printing all params if debug is enabled
	if ($params{'verbose'}) {
		say @_;
	}
}

# $regex, $type ('m'/'s')
sub validate_regex {
	croak "Wrong number of arguments: ".@_ if @_ != 2;

	my $regex = shift;
	my $type = shift;

	my $valid_fail = 0;

	if ($type eq "m") {
		if ($regex =~ /(^\/{1}.*?\/{1})(.*$)/ ) {
			# catching first /a/ and checking if something
			# else exist in case of //////
			if ($2) {
				$valid_fail = 1;
			}
		} else {
			# bad regex at all
			$valid_fail = 1;
		}
	} else {
		die "Bad regex type: $type";
	}

	if ($valid_fail) {
		die "Bad regex: $regex"
	}

	say_d "Regex $regex validation ok";
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

		if ($word_counter % $max_n_words == 0) {
			# printing end of line
			print "$params{'end-line-prefix'}\n";
			$was_flushed = 1;
		} else {
			$was_flushed = 0;
		}
	}

	sub flush_if_needed {
		if (!$was_flushed) {
			print "\n";
		}
	}
}

## $str, $regex
sub check_match {
	croak("Wrong number of arguments: ".@_) if @_ != 2; #TODO: croak

	my $str = shift;
	my $regex = shift;

	if ($str eq '') {
		say_d "Skipping match for string $str because regex empty with 0 exit..";
		return 0;
	}

	validate_regex($regex, "m");
	# Applying word regex if passed as a param
	my $wquery = "qr$regex";

	if ($str =~ eval($wquery)) {
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

### Start ####
pod2usage(0) if $params{'help'};

say_d 'Using column size: '.$params{'num-words'};
say_d 'Using word regex: '.$params{'match-word-regex'};
say_d 'Using exclude word regex: '.$params{'exclude-word-regex'};
say_d "End line prefix: $params{'end-line-prefix'}";

my $wcount = 1; # word counter
while (my $line = <STDIN>) {
	chomp($line);

	my @words_in_line = split($params{'split-delim'}, $line);
	my @columns_idx_arr;
	# if user has given columns, then using it now..
	if ($params{'columns-selected'}) {
		# TODO: validate!
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
		if ($col_idx > $#words_in_line) {
			say_d "In line <$line> caught out of bounds index ".($col_idx + 1).
				" Moving on...";
			next;
		}
		my $word = $words_in_line[$col_idx];

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
[ --match-word-regex|-m '/match/' ]
[ --exclude-word-regex|-M '/negative_match/']
[ --end-line-prefix|-e '' ]
[ --output-word-separator|-w ' ' ]

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

number of words per line that will be generated in output stream.

=item B<--split-delim ' '> or B<-d ' '>

delimiter of words in line in INPUT stream - used when each input line consists of more than one field

=item B<--match-word-regex '/match/'> or B<-m '/match/'>

print only WORDS that matching given regex e.g.: -m '/a/' will print only words containing 'a' and rest will be filtered out

=item B<--exclude-word '/negative_match/'> or B<-M '/negative_match/'>

Reversed version of -m parameter - skip words if match exists

=item B<--end-line-prefix ''> or B<-e ''>

set separator that is printed on end of every line just before newline marker.e.g: -e '\' will result in:

=item a,b,c\

=item d,e,f

=item

=item B<--output-word-separator ' '> or B<-w ' '>
-
set separator that is used after every printed word. At default one whitespace is used (' '). e.g: -o ',' will result in:

=item a,b,c

=item d,e,f

=item

=item B<--verbose> or B<-v>

prints additional debug information

=item B<--help> or B<-h>

this help information

=back
