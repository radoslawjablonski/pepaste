#! /usr/bin/perl -w

use 5.14.0; # for 'say'
use strict;
use Getopt::Long qw(:config bundling); # for case sensitive
use Pod::Usage qw(pod2usage);;

my %params = ('num-words' => 2,
			  'split-delim' => ' ',
			  'match-word-regex' => '',
			  'match-line-regex' => '',
			  'verbose' => 0,
			  'end-line-prefix' => '',
			  'output-word-separator' => ' ',
			  'help' => 0);

GetOptions('num-words|n=i' => \$params{'num-words'},
		   'split-delim|d=s' => \$params{'split-delim'},
		   'match-word|m=s' =>  \$params{'match-word-regex'},
		   'match-line-regex|M=s' => \$params{'match-line-regex'},
		   'verbose|v' => \$params{'verbose'},
		   'end-line-prefix|e=s' => \$params{'end-line-prefix'},
		   'output-word-separator|o=s' => \$params{'output-word-separator'},
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
	die "Wrong number of arguments: ".@_ if @_ != 2;

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
		die "Wrong number of arguments: ".@_ if @_ != 3;

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
	die "Wrong number of arguments: ".@_ if @_ != 2;

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

### START ####
pod2usage(0) if $params{'help'};

say_d 'Using column size: '.$params{'num-words'};
say_d 'Using word regex: '.$params{'match-word-regex'};
say_d 'Using line regex: '.$params{'match-line-regex'};
say_d "End line prefix: $params{'end-line-prefix'}";

my $wcount = 1; # word counter
while (my $line = <>) {
	chomp($line);

	if ($params{'match-line-regex'} ne '') {
		# print 'Using line regex: ', $params{'R'};
		#TODO implement
		...
	}

	foreach my $word (split($params{'split-delim'}, $line)) {
		# skipping for match-word-regex if didn't matched
		if ($params{'match-word-regex'} &&
				!check_match($word, $params{'match-word-regex'})) {
			say_d "Skipping $word because of match-word-regex";
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

$ pepaste [-vh ] [ --num-words|-n NUM ]
[ --split-delim|-d ' ' ]
[ --match-word|-m '/match/' ]
[ --match-line-regex|-M '/match/' ]
[ --end-line-prefix|-e '' ]
[ --output-word-separator|-w ' ' ]
input_file

=head1 OPTIONS

=over 8

=item B<--num-words N> or B<-n N>

number of words per line that will be generated in output stream.

=item B<--split-delim ' '> or B<-d ' '>

delimiter of words in line in INPUT stream - used when each input line consists of more than one field

=item B<--match-word '/match/'> or B<-m '/match/'>

print only WORDS that matching given regex e.g.: -m '/a/' will print only words containing 'a' and rest will be filtered out

=item B<--match-line-regex '/match/'> or B<-M '/match/'>

print only LINES that matching given regex e.g.: -m '/^a/' will print only lines starting with 'a' and rest of the input lines be filtered out

=item B<--end-line-prefix ''> or B<-e ''>

set separator that is printed on end of every line just before newline marker.e.g: -e '\' will result in:
a,b,c\
d,e,f

=item B<--output-word-separator ' '> or B<-w ' '>

set separator that is used after every printed word. At default one whitespace is used (' '). e.g: -o ',' will result in:
a,b,c
d,e,f

=item B<--verbose> or B<-v>

prints additional debug information

=item B<--help> or B<-h>

this help information

=back
