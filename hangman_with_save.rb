require 'yaml'

class Hangman
  attr_accessor :hangman
  
  def initialize
    @hangman = HangmanGame.new
  end
  
  def save_game(game)
    yaml = YAML::dump(game)
    save_file = File.open("save_game.txt", "w").write(yaml)
    #use "w" only to overwrite completely in case multiple games are saved in succession
    puts "*** Game saved! See you soon! ***"
  end

  def load_game
    if File::exist?("save_game.txt")
      save_file = File.open("save_game.txt", "r")
      #this method serves to read only, hence the "r"
      YAML::load(save_file)
      puts "*** Saved game successfully loaded! ***"
    else
      puts "*** No save game data present. Let's start a new game! ***"
      @hangman.begin_game
    end
  end
  
  def new_game?
    puts "Welcome to Hangman! You can either:"
    puts " -- Start a NEW game"
    puts " -- LOAD a saved game"
    puts " -- EXIT the program"
    puts "Enter 'new', 'load', or 'exit' to proceed. "
    
    response = gets.chomp.downcase
    
    if response == "load"
      load_game
    elsif response == "new"
      @hangman.begin_game
    elsif response == "exit"
      puts "Thanks for playing!"
      exit
    else
      puts "Invalid entry.  Please enter either 'new' or 'load'."
    end
  end
  
end

class HangmanGame < Hangman
  attr_reader :word
  attr_accessor :board
  
  def initialize
    @word = get_word_to_guess
    @board = Array.new(@word.length) { "_" }
  end
  
  def reveal(letter, word)
    indices = []
    word.split("").each_index { |index| indices << index if word[index] == letter }
    indices.each { |i| @board[i] = letter }
  end
  
  def win?
    @board.join == @word ? true : false
  end
  
  def has_been_guessed(input, array)
    array.join.include?(input) ? true : false
  end
  
  #invalid if input is > 1 or is not a letter;
  # \W strains non-letters AND non-digits, while \d further strains for digits
  def invalid_entry?(input)
    (input.length > 1 || input =~ /\W/ || input =~ /\d/ ) ? true : false
  end
  
  def show_turn_message(turns)
    if turns == 1 
      puts "Only #{turns} turn left. Pick wisely, or type 'save' to save the game."
    else 
      puts "#{turns} turns left. Enter a letter, or type 'save' to save the game."
    end
  end
  
  def play_again?
    puts "*** Play again? Type 'yes' or 'no'. *** "
    answer = gets.chomp.downcase
    if answer == "yes"
      Hangman.new.new_game?
    elsif answer == "no"
      puts "All right, see you soon!"
      exit
    else
      puts "Invalid response; type 'yes' or 'no'. "
      play_again?
    end
  end
  
  def begin_game
    turns = 5
    incorrect_guesses = []
    exclamations = ["Awesome!", "Cool!", "Amazing!", "Yep!", "Way to go!"]
    
    while turns > 0
      random_exclamation = exclamations[rand(exclamations.length)]
      
      show_turn_message(turns)
      puts "Incorrect guesses: " + incorrect_guesses.join(" ")
      print @board.join(" ") + "     "
      
      guess = gets.chomp.downcase
      
      if guess == 'save'
        save_game(@hangman)
        Hangman.new.new_game?
      elsif invalid_entry?(guess)
        puts "*** Your entry is invalid.  Please enter a single letter. ***"
      elsif has_been_guessed(guess, incorrect_guesses) || has_been_guessed(guess, @board)
        puts "*** You've already guessed '#{guess}'.  Enter a different one. ***"
      elsif @word.include? guess
        puts "*** #{random_exclamation} ***"
        reveal(guess, @word)
        if win?
          puts @board.join(" ")
          puts "*** CONGRATS, you win! ***"
          play_again?
        end
      else
        puts "*** Sorry, that's not in the word! ***"
        incorrect_guesses << guess
        turns -= 1
      end
    end
    #to prevent showing both 'win' and 'loss' messages in the case where 
    #the player solves the game on the last turn
    if !win?
      puts "*** You lose! The word was '#{@word}'. Better luck next time! ***"
      play_again?
    end
  end
  
  protected
  
  def get_word_to_guess
    dictionary = File.open("dictionary.txt", "r")
    dictionary_array = dictionary.readlines.select { |word| word.length.between?(5, 12) }
    word_to_guess = dictionary_array[rand(dictionary_array.length)].chop.downcase 
      #chop to remove "/r/n" at the end
      #since some words in the dictionary begin with a capital letter
    word_to_guess
  end

end

Hangman.new.new_game?

