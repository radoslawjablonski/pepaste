#! /usr/bin/perl -w

use strict;
use Getopt::Long qw(:config bundling); # for case sensitive
use Pod::Usage qw(pod2usage);;

my %params = ('hex-locate' => '',
              'string-locate' => ''
          );

GetOptions('hex-locate|h=s' => \$params{'hex-locate'},
           'string-locate|s=s' => \$params{'string-locate'},
       )
	or pod2usage(-verbose => 0);
;

my $locate_mode = 0;
my $chars = "ABCDEFGHIJKLMNOPRSTUWXYZ123456789abcdef";
my $chars_count = length($chars);
my $max_tokens = $chars_count * $chars_count;

my $token_count = 0;
my $out_str = "";
for (my $i = 0; $i < $chars_count; ++$i) {
    for (my $j = 0; $j < $chars_count; ++$j) {
        if ($token_count >= $max_tokens) {
            exit 0;
        }
        $out_str .= substr($chars, $i, 1) . substr($chars, $j, 1);
        ++$token_count;
    }
}

if ($params{'hex-locate'}) {
    #print "Trying to hex-locate $params{'hex-locate'}\n";
    $locate_mode = 1;

    $params{'string-locate'} = reverse pack("H*", $params{'hex-locate'});
}

if ($params{'string-locate'}) {
    $locate_mode = 1;
    $params{'hex-locate'} = unpack("H*", $params{'string-locate'});
}

if ($locate_mode) {
    printf "Locating string $params{'string-locate'} (hex $params{'hex-locate'})\n";
    my $i = index($out_str, $params{'string-locate'});
    if ($i != -1) {
        printf("Found at byte index %d\n", $i);
        my $idx_min = ($i - 5 > 0) ? $i - 5 : 0;
        my $idx_after = $i + length($params{'string-locate'});

        # print context info
        printf("%s[%s]%s\n",
               substr($out_str, $idx_min, $i - $idx_min),
               $params{'string-locate'},
               substr($out_str, $idx_after, 5));
    } else {
        # TODO: print hex representation in (where hex is used)
        die "Pattern $params{'string-locate'} not found!\n";
    }
} else {
    print $out_str;
}

=head1 SYNOPSIS

Produces output string sequence if no params added or can locate
given sequence (hex-formatted or raw string)
$ pattern_create.pl [-h|--hex-locate] [-s|--string-locate]

