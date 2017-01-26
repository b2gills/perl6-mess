#!/usr/bin/env perl
use 5.024;
use warnings;
use utf8;
use Encode;
use List::Util qw(any);
use Term::ANSIColor qw(colored);
use Tie::File;


sub pick_word {
    tie my @lines, 'Tie::File', 'data/dict.txt'
        or die "Can't open dictionary: $!\n";
    return decode 'UTF-8', $lines[int rand @lines];
}

# split by grapheme cluster boundary
my @letters = split /\b{gcb}/, pick_word;


sub u {
    return map { encode 'UTF-8', $_ } @_;
}

sub visible_letters {
    my $str = join ' ', map { $guessed{fc $_} ? $_ : '–' } @letters;
    say u "\n$str\n";
    return $str;
}

sub color {
    my ($letter) = @_;
    my $in_word = any { fc $letter eq fc } @letters;
    return colored($letter, $in_word ? 'green' : 'red');
}


my %guessed;

sub guess_letter {
    say u join ' ', map { color($_) } sort keys %guessed;

    GUESS: {
        print "Guess? > ";
        STDOUT->flush;

        my $guess = <> // die "end of input\n";
        $guess =~ s/^\s+|\s+$//g; # trim

        # \X is a grapheme cluster
        unless ($guess =~ /^\X$/) {
            warn "Type one letter to guess.\n";
            redo GUESS;
        }

        if ($guessed{fc $guess}) {
            warn "You already guessed that letter.\n";
            redo GUESS;
        }

        $guessed{fc $guess} = 1;
        return $guess;
    }
}


guess_letter while visible_letters =~ /–/;
