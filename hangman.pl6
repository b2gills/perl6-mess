sub exit-success { exit 0 }

subset Char     of Str:_  where !.defined || .chars == 1;
constant CharList = Str:D;
subset WordList of List:D where .all ~~ CharList;

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
sub term:<random-word>() returns CharList { game-words.&random-word }

class Puzzle {
    has CharList $.answer is required;
    has Char:_ @.discovered;
    has Char:D @.guessed;
    
    multi method new(
        $answer,
        @discovered,
        @guessed
    ){
        samewith :$answer, :@discovered, :@guessed;
    }
    submethod BUILD (:$!answer,:@!discovered?,:@!guessed?) {
        @!discovered ||= Str xx $!answer.chars;
    }
    
    method Str() { self.show }
    method show() returns CharList {
        join(' ',map( &render-puzzle-char, @!discovered )) ~ 
        " Guessed so far: " ~ @!guessed
    }
}

sub show(Puzzle:D \puzzle) returns CharList { puzzle.show }

sub fresh-puzzle(CharList \s) returns Puzzle:D { Puzzle.new: s, (Str xx s.chars), () }

multi render-puzzle-char(Char:U $ ) returns Char:D { "_" }
multi render-puzzle-char(Char:D \c) returns Char:D {  c  }

sub char-in-word(Puzzle:D \puzzle, Char:D \c) returns Bool:D {
    puzzle.answer.contains: c
}

sub already-guessed(Puzzle:D \puzzle, Char:D \c) returns Bool:D {
    puzzle.guessed (cont) c
}

sub fill-in-character(
    Puzzle:D \puzzle (
        :answer($word),
        :discovered(@filled-in-so-far),
        :guessed(@s),
        *%
    ),
    Char:D \c
) returns Puzzle:D {
    sub zipper (Char:D \guessed) returns Callable:D {
        -> Char:D \word-char, Char:_ \guess-char --> Char:_ {
            if word-char eq guessed {
                word-char
            } else {
                guess-char
            }
        }
    }

    my \new-filled-in-so-far =
        zip :with(zipper c), $word.comb, @filled-in-so-far;

    Puzzle.new: $word, new-filled-in-so-far, (c,|@s)
}

sub handle-guess(Puzzle:D \puzzle, Char:D \guess) returns Puzzle:D {
    put "Your guess was: ", guess;
    given
        char-in-word(puzzle, guess),
        already-guessed(puzzle, guess)
    {
        when (*, :so) {
            put "You already guessed that character, pick something else!";
            return puzzle;
        }
        when (:so, *) {
            put "This character was in the word, filling in the word accordingly";
            return fill-in-character puzzle, guess;
        }
        when (:not, *) {
            put "This character wasn't in the word, try again";
            return fill-in-character puzzle, guess;
        }
    }
}

sub game-over(Puzzle:D \puzzle (:answer($word-to-guess), :@guessed, *%)) {
    if @guessed > 7 {
        put 'You lose!';
        put 'The word was: ', $word-to-guess;
        exit-success
    }
}

sub game-win(Puzzle:D \puzzle (:discovered(@filled-in-so-far), *%)) {
    if @filled-in-so-far.all.defined {
        put 'You win!';
        exit-success;
    }
}

sub run-game(Puzzle:D \puzzle) {
    loop {
        game-over puzzle;
        game-win puzzle;
        put 'Current puzzle is: ', show puzzle;
        my \guess = prompt 'Guess a letter: ';
        given guess {
            when Char {
                run-game handle-guess puzzle, guess;
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
