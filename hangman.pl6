subset Strs of List where { $_.all ~~ Str };
subset Char of Str where { $_.chars ~~ 1 };

sub all-words() returns Strs {
    #read dictionary file
    #return the lines of the file as a wordlist
}

sub random-word(WordList @list) returns Str {
    #pick random number
    #return a word from wordlist
}

class Puzzle {
    has Str $answer;
    has Str @discovered;
    has Str @guessed;
}

# Figure out the method to build string representations of objects
#
#instance Show Puzzle where
  #show (Puzzle _ discovered guessed) =
    #(intersperse ' ' $ fmap renderPuzzleChar discovered) ++ " Guessed so far: " ++ guessed

sub fresh-puzzle(Str $s) returns Puzzle {}

multi render-puzzle-char(Char:U $c) returns Char { "_" }
multi render-puzzle-char(Char:D $c) returns Char { $c  }

sub char-in-word(Puzzle $puzz, Char $char) returns Bool {}

sub already-guessed(Puzzle $puzz, Char $char) returns Bool {}

sub fill-in-character(Puzzle $puzz, Char $char) returns Puzzle {}
