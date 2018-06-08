#! /usr/bin/perl -w

use strict;

use Test::More;

sub basic_test {
	my $data_gen_cmd = shift;
	my $pepaste_params = shift;
	my $expected_str = shift;

	my $output = `$data_gen_cmd|../pepaste $pepaste_params`;

	cmp_ok ($output, "eq", $expected_str, "Three words in one line, params: ".$pepaste_params);
}

sub three_words_in_line_test {
	my $pepaste_params = shift;
	my $expected_str = shift;

	basic_test("echo aa bb cc", $pepaste_params, $expected_str);
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
