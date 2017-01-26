subset Char     of Str  where { $_.chars == 1        };
subset CharList of List where { $_.all   ~~ Char     };
subset WordList of List where { $_.all   ~~ CharList };

sub all-words() returns WordList {
    #read dictionary file
    #get the lines of the file
    #comb all words and return as a wordlist
}

my Int $min-word-length = 5;
my Int $max-word-length = 9;

sub game-words() returns WordList {
    #  WordList aw <- allWords
    #  return $ WordList (filter gameLength aw)
    #  where gameLength w =
    #          let l = length (w :: String)
    #          in  l < minWordLength && l < maxWordLength
}

sub random-word(WordList @list) returns Str {
    #pick random number
    #return a word from wordlist
}

class Puzzle {
    has Str $.answer;
    has CharList @.discovered;
    has CharList @.guessed;
    
    method Str() {
        #instance Show Puzzle where
        #show (Puzzle _ discovered guessed) =
        #(intersperse ' ' $ fmap renderPuzzleChar discovered) ++ " Guessed so far: " ++ guessed
    }
}

sub fresh-puzzle(Str $s) returns Puzzle {}

multi render-puzzle-char(Char:U $c) returns Char { "_" }
multi render-puzzle-char(Char:D $c) returns Char { $c  }

sub char-in-word(Puzzle $puzz, Char $char) returns Bool {}

sub already-guessed(Puzzle $puzz, Char $char) returns Bool {}

sub fill-in-character(Puzzle $puzz, Char $char) returns Puzzle {}
