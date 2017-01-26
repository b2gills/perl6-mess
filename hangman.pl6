subset Char     of Str  where { $_.chars == 1        };
#subset CharList of List where { $_.all   ~~ Char     };
constant CharList = Str; # makes things much simpler
subset WordList of List where { $_.all   ~~ CharList };

my \dictionary = (
    first * ~~ :e,
    map *.?IO,
    %*ENV<dictionary>, 'data/dict.txt', '/usr/share/dict/words', '/usr/dict/words'
);

sub all-words() returns WordList {
    dictionary.lines # returns a Seq
    .List            # turn it into a List to satisfy WordList
}
# Haskell has a single namespace for functions and variables
# Let's fake that here by pretending all-words was a variable
my &term:<all-words> = &all-words;

my Int \min-word-length = 5;
my Int \max-word-length = 9;

sub game-words() returns WordList {
    all-words # term:<all-words>()
    .grep({ min-word-length <= .chars <= max-word-length})
    .List # turn it into a List to satisfy WordList
}
my &term:<game-words> = &game-words;

sub random-word(WordList \list) returns CharList {
    list.pick
}
# replacement for randomWord'
sub term:<random-word>() { game-words.&random-word }

class Puzzle {
    has Str $.answer is required;
    has CharList @.discovered;
    has %.guessed;
    
    method Str() {
        #instance Show Puzzle where
        #show (Puzzle _ discovered guessed) =
        #(intersperse ' ' $ fmap renderPuzzleChar discovered) ++ " Guessed so far: " ++ guessed
    }
}

sub show(Puzzle \puzzle) {
    ...
}

sub fresh-puzzle(Str \s) returns Puzzle { Puzzle.new: s }

multi render-puzzle-char(Char:U $c) returns Char { "_" }
multi render-puzzle-char(Char:D $c) returns Char { $c  }

sub char-in-word(Puzzle \puzzle, Char \c) returns Bool {
    puzzle.answer.contains: c
}

sub already-guessed(Puzzle \puzzle, Char \c) returns Bool {
    puzzle.guessed (cont) c
}

sub fill-in-character(Puzzle $puzz, Char $char) returns Puzzle {}

sub handle-guess(Puzzle \puzzle, Char \c) {
    ...
}

sub game-over(Puzzle \puzzle) {
    ...
}

sub game-win(Puzzle \puzzle) {
    ...
}

sub run-game(Puzzle \puzzle) {
    loop {
        game-over puzzle;
        game-win puzzle;
        put 'Current puzzle is: ', show puzzle;
        my \guess = input 'Guess a letter: ';
        given guess {
            when Char {
                handle-guess puzzle, c, &run-game;
            }
            default {
                put 'Your guess must be a single character'
            }
        }
    }
}

sub MAIN() {
    my \word = random-word;
    my \puzzle = fresh-puzzle word.lc;
    run-game puzzle
}
