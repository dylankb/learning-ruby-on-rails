require 'yaml'
require 'pry'

MESSAGES = YAML.load_file('messages.yml')

module Sayable
  def say(msg)
    puts "=> #{msg}"
  end
end

module Deduceable
  attr_reader :move_history

  def find_common_move(other_player, move_history)
    move_counts = []
    move_history[other_player.class.to_s].each do |m|
      move_counts << move_history[other_player.class.to_s].count(m)
    end
    move_counts.sort!
    high_count = move_counts[-1]
    move_index = move_counts.index(high_count)
    return move_history[other_player.class.to_s][move_index]
  end

  def find_common_countermove(other_player, move_history)
    common_move = find_common_move(other_player, move_history)
    counter_moves_hsh = RPSGame::WIN_MOVE.select { |k,v| v.include?(common_move) }
    counter_moves = counter_moves_hsh.keys
  end
end

class Player
  include Sayable
  attr_accessor :move, :name, :wins, :won_game

  def initialize
    @wins = 0
    get_name
  end
end

class Human < Player

  def get_name
    say MESSAGES['name']
    loop do
      self.name = gets.chomp
      break unless name.empty?
      say MESSAGES['check_name']
    end
  end

  def choose
    loop do 
      say MESSAGES['hand_choice']
      self.move = gets.chomp
      break if RPSGame::MOVES.keys.include?(move)
      say MESSAGES['confirm_choice']
    end
  end
end

class Computer < Player
  include Deduceable

  def get_name
    self.name = ['C3PO', 'Wall-E', 'BB8'].sample
  end
  
  def choose(other_player, move_history)
    if !move_history.empty?
      self.move = find_common_countermove(other_player, move_history).sample
    else
      self.move = RPSGame::MOVES.keys.sample
    end
  end
end

class RPSGame
  include Sayable
  include Deduceable
  attr_accessor :human, :computer, :move_history

  MOVES = {'r'=>'rock', 'p'=>'paper', 'sc'=>'scissors' ,'l'=>'lizard', 'sp'=>'spock'}
  WIN_MOVE = {'r' => ['sc', 'l'],'sc' => ['p', 'l'],
          'p' => ['r', 'sp'], 'l' => ['p', 'sp'],
          'sp' => ['r', 'sc']}
  GAMES_TO_WIN = 3

  def initialize
    @human = Human.new
    @computer = Computer.new
    self.move_history = {}
  end

  def game_intro
    say MESSAGES['intro_question']
    loop do
      answer = gets.chomp.downcase
      if answer == 'y'
        say MESSAGES['game_start']
        break
      elsif answer == 'n'
        say MESSAGES['explanation']
      else
        say MESSAGES['wrong_y-n_response']
      end
    end
  end

  def record_move(player, move)
    move_history[player.class.to_s] ||= []
    move_history[player.class.to_s] << player.move
  end

  def display_games_won
    say "#{human.name}: #{human.wins} | #{computer.name}: #{computer.wins}"
  end

  def evaluate_game_winner
    if WIN_MOVE[human.move].include?(computer.move)
      human.won_game = true
      human.wins += 1
    elsif WIN_MOVE[computer.move].include?(human.move)
      computer.won_game = true
      computer.wins += 1
    end
  end

  def display_moves
    if human.won_game
      say "#{human.name} wisely chose #{MOVES[human.move]}."
    else
      say "#{human.name} chose #{MOVES[human.move]}."
    end
    if computer.won_game
      say "#{computer.name} wisely chose #{MOVES[computer.move]}"
    elsif human.move == computer.move
      say "#{computer.name} also chose #{MOVES[computer.move]}"
    else
      say "#{computer.name} chose #{MOVES[computer.move]}"
    end
  end

  def display_winner
    if human.won_game
      say "#{human.name} won!"
    elsif computer.won_game
      say "#{computer.name} won!"
    else
      say MESSAGES['tie']
    end
  end

  def reset_won_game
    human.won_game = nil
    computer.won_game = nil
  end

  def play_again?
    say MESSAGES['ask_play_again']
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if answer.start_with?('y','n')
      say MESSAGES['wrong_y-n_response']
    end
    answer.start_with?('y')
  end

  def evaluate_match_winner
    if human.wins == GAMES_TO_WIN
      "#{human.name} won the match!!"
    elsif computer.wins == GAMES_TO_WIN
      "#{computer.name} won the match!!"
    end
  end

  def match_over?
    !!evaluate_match_winner
  end

  def display_match_winner
    say evaluate_match_winner
  end

  def display_goodbye_message
    say MESSAGES['goodbye']
  end

  def play
    game_intro
    loop do
      display_games_won
      human.choose
      computer.choose(human, move_history)
      record_move(human, human.move)
      record_move(computer, computer.move)
      evaluate_game_winner
      display_moves
      display_winner
      if match_over?
        display_match_winner
        break
      end
      reset_won_game
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play