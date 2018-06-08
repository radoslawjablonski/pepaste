#! /usr/bin/perl -w

use Test::More;

sub three_words_in_line_test {
	my $cmd_params = shift;
	my $expected_str = shift;

	my $output = `echo aa bb cc|../pepaste $cmd_params`;

	cmp_ok ($output, "eq", $expected_str, "Three words in one line, params: ".$cmd_params);
}

# Three words in line, no params (default n=1)
my $expected = "aa
bb
cc
";
three_words_in_line_test("", $expected);

# Three words in line, n=2
my $expected = "aa bb
cc
";
three_words_in_line_test("-n 2", $expected);


done_testing();
