#! /usr/bin/perl -w

use strict;

use Test::More;

sub basic_test {
	my $data_gen_cmd = shift;
	my $pepaste_params = shift;
	my $expected_str = shift;
	my $test_name = shift;

	my $output = `$data_gen_cmd|../pepaste $pepaste_params`;

	cmp_ok ($output, "eq", $expected_str, "$test_name, pepaste params: ".$pepaste_params);
}

sub three_words_in_line_test {
	my $pepaste_params = shift;
	my $expected_str = shift;

	basic_test("/bin/echo aa bb cc", $pepaste_params, $expected_str, "Three words in line");
}

sub three_words_in_sep_lines_test {
	my $pepaste_params = shift;
	my $expected_str = shift;

	basic_test("/bin/echo -e 'aa\nbb\ncc\n'", $pepaste_params, $expected_str, "Three words in separated lines");
}

sub three_words_all_modes_test {
	my $pepaste_params = shift;
	my $expected_str = shift;

	three_words_in_line_test($pepaste_params, $expected_str);
	three_words_in_sep_lines_test($pepaste_params, $expected_str);
}

sub empty_input_test {
	my $pepaste_params = shift;
	my $expected_str = shift;

	basic_test("/bin/echo", $pepaste_params, $expected_str, "Empty input");
}

# Three words in line, no params (default n=1)
my $expected = "aa
bb
cc
";
three_words_all_modes_test("", $expected);

# Three words in line, only end-line string passed
my $expected = "aa\\
bb\\
cc\\
";
three_words_all_modes_test("-e '\\'", $expected);


# Three words in line, n=2
$expected = "aa bb
cc
";
three_words_all_modes_test("-n 2", $expected);


# Empty inputs tests, nothing should be generated
$expected = "";
empty_input_test("", $expected);
empty_input_test("-n 3", $expected);
empty_input_test("-e '\\'", $expected);


done_testing();
