#! /usr/bin/perl

use warnings;
use strict;
use Getopt::Long qw(:config bundling); # for case sensitive
use Pod::Usage qw(pod2usage);;
use Cwd;
use File::Copy;

my %params = ('symlink' => 0,
			  'out-dir' => "/usr/local/bin/",
			  'help' => 0);

GetOptions('symlink|s' => \$params{'symlink'},
		   'prefix|p=s' => \$params{'out-dir'},
		   'help|h' => \$params{'help'});

=head1 SYNOPSIS

Installs all files by copying or creating symling in target (prefix) directory.
Copy-mode is set by default

$ install.pl
[ --symlink|-s ]
[ --prefix|p DIR_PATH]
[ --help|-h ]

=cut

if ($params{'help'}) {
	pod2usage(0);
}

my @files_to_install = (`ls`);
foreach my $file (@files_to_install) {
	chomp($file);
	if (index($0, $file) > -1) {# FIX!
		print "Ignoring $0....\n";
		next;
	}
	install_file($file, $params{'out-dir'});
}

sub install_file {
	my $prog_name = shift;
	my $install_dir = shift;

	my $curr_dir = cwd()."/";
	my $source_path = $curr_dir.$prog_name;
	my $output_path = $install_dir.$prog_name;

	if ($params{'symlink'}) {
		print("Creating Symlink in $output_path...");
		symlink($source_path, $output_path)
			or die "Can't create symlink $output_path: $!";
	}else {
		print("Creating copy in $output_path...");
		copy($source_path, $output_path)
			or die "Can't copy file to: $output_path: $!";
	}

	print "Success!\n";
}
