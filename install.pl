#! /usr/bin/perl

use warnings;
use strict;
use Getopt::Long qw(:config bundling); # for case sensitive
use Pod::Usage qw(pod2usage);;
use Cwd;
use File::Copy;

my %params = ('symlink' => 0,
			  'help' => 0);

GetOptions('symlink|s' => \$params{'symlink'},
		   'help|h' => \$params{'help'});

=head1 SYNOPSIS

Installs 'pepaste' by copying or creating symling in /usr/local/bin/ directory.
Copy-mode is set by default

$ install.pl
[ --symlink|-s ]
[ --help|-h ]

=cut

if ($params{'help'}) {
	pod2usage(0);
}

my $curr_dir = cwd()."/";
my $out_dir = "/usr/local/bin/";

my $source_path = $curr_dir.'pepaste.pl';
my $output_path = $out_dir.'pepaste';

if ($params{'symlink'}) {
	print("Symlink mode\n");
	symlink($source_path, $output_path)
		or die "Can't create symlink $output_path: $!";
}else {
	print("Copy mode\n");
	copy($source_path, $output_path)
		or die "Can't copy file to: $output_path: $!";
}

print "Installed successfully at $output_path\n";
