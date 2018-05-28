#! /usr/bin/perl -w

use strict;
use 5.14.0; # for 'say'

use Getopt::Long qw(:config bundling); # for case sensitive
#todo help finction
my %params = ('num-words' => 2,
			  'split-delim' => ' ',
			  'match-word-regex' => '',
			  'match-line-regex' => '',
			  'verbose' => '0',
			  'end-line-prefix' => '',
			  'output-word-separator' => ' ');

GetOptions('num-words|n=i' => \$params{'num-words'},
		   'split-delim|d=s' => \$params{'split-delim'},
		   'match-word|m=s' =>  \$params{'match-word-regex'},
		   'M=s' => \$params{'match-line-regex'},
		   'verbose|v' => \$params{'verbose'},
		   'end-line-prefix|e=s' => \$params{'end-line-prefix'},
		   'output-word-separator|o=s' => \$params{'output-word-separator'}
	   )
	or die 'Invalid parameters';

#TODO: help info

sub say_d {
	# printing all params if debug is enabled
	if ($params{'verbose'}) {
		say @_;
	}
}

# $regex, $type ('m'/'s')
sub validate_regex {
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

say_d 'Using column size: '.$params{'num-words'};
say_d 'Using word regex: '.$params{'match-word-regex'};
say_d 'Using line regex: '.$params{'match-line-regex'};
say_d "End line prefix: $params{'end-line-prefix'}";

{
	# use for tracking if newline is needed on end of the program
	my $was_flushed = 1;
	
	sub print_word {
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

my $wcount = 1; # word counter
while (my $line = <>) {
	chomp($line);

	if ($params{'match-line-regex'} ne '') {
		# print 'Using line regex: ', $params{'R'};
		#TODO implement
		...
	}

	foreach my $word (split($params{'split-delim'}, $line)) {
		if ($params{'match-word-regex'} ne '') {
			validate_regex($params{'match-word-regex'}, "m");
			# Applying word regex if passed as a param
			my $wquery = "qr$params{'match-word-regex'}";

			if ($word !~ eval($wquery)) {
				say_d "<omit $word>";
				next;
			}
		}

		print_word($word, $params{'num-words'}, $wcount);
	
		$wcount++;
	}
}

# flushing on the end - it causes problems on some shells
# if not flushed..
flush_if_needed;
