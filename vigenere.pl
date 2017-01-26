#!/usr/bin/env perl
use 5.024;
use warnings;
use utf8;


die "Usage: $0 e|d KEYWORD TEXT\n" unless @ARGV == 3;


my $mode = fc shift;
my $op;

if ($mode eq 'e') {
    $op = sub { $_[0] + $_[1] };
}
elsif ($mode eq 'd') {
    $op = sub { $_[0] - $_[1] };
}
else {
    die "Specify 'e' for encrypt or 'd' for decrypt as the first parameter.\n";
}


my $keyword = fc shift;

unless ($keyword =~ /^[a-z]+$/) {
    die "keyword can only contain letters A to Z\n";
}


sub vigenize {
    my ($letter) = @_;
    state $pos = 0;

    my $index  = $pos++ % length $keyword;
    my $shift  = ord(substr $keyword, $index, 1) - ord('a');
    my $base   = ord(lc $letter)                 - ord('a');
    my $result = chr($op->($base, $shift) % 26   + ord('a'));

    return $letter =~ /\p{Lu}/ ? uc $result : $result;
}


say shift =~ s/([a-z])/vigenize($1)/egir;
