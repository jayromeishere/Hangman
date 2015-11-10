class Hangman
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
      puts "Only #{turns} turn left. Pick wisely!"
    else 
      puts "#{turns} turns left. Enter a letter."
    end
  end
 
  def game
    turns = 5
    incorrect_guesses = []
    exclamations = ["Awesome!", "Cool!", "Amazing!", "Yep!", "Way to go!"]
    
    while turns > 0
      random_exclamation = exclamations[rand(exclamations.length)]
      
      show_turn_message(turns)
      puts "Incorrect guesses: " + incorrect_guesses.join(" ")
      print @board.join(" ")
      
      guess = gets.chomp.downcase
      
      if invalid_entry?(guess)
        puts "*** Your entry is invalid.  Please enter a single letter. ***"
      elsif has_been_guessed(guess, incorrect_guesses) || has_been_guessed(guess, @board)
        puts "*** You've already guessed '#{guess}'.  Enter a different one. ***"
      elsif @word.include? guess
        puts "*** #{random_exclamation} ***"
        reveal(guess, @word)
        if win?
          print @board.join(" ")
          print " CONGRATS, you win!!!!!! "
          break
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

Hangman.new.game