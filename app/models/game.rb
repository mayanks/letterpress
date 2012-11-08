class Game < ActiveRecord::Base
  attr_accessible :letters, :player_a_id, :player_a_score, :player_b_id, :player_b_score, :state
  serialize :letters, Array
  serialize :words, Array
  belongs_to :player_a, :class_name => "User"
  belongs_to :player_b, :class_name => "User"

  before_create :create_letters

  SIZE = 5
  CONSOLE_COLOR = [nil, :blue, :red]

  STATE_NEW = 0
  STATE_WAITING = 1
  STATE_ACTIVE = 2
  STATE_P1_WAITING = 3
  STATE_P2_WAITING = 4
  STATE_P1_CANCELLED = 5
  STATE_P2_CANCELLED = 6
  STATE_COMPLETE = 7

  def can_move?(user)
    return true if self.state == STATE_NEW and user == player_a
    return true if self.state == STATE_P1_WAITING and user == player_a
    return true if self.state == STATE_P2_WAITING and user == player_b
    return false
  end

  def status_string(user)
    if state == STATE_NEW
      "New Game"
    elsif state == STATE_WAITING
      "Waiting for your opponent"
    elsif state == STATE_ACTIVE
      "Game Active"
    elsif state == STATE_P1_WAITING
      if user == player_a
        "Your Turn"
      else
        "#{player_a.name}'s Turn"
      end
    elsif state == STATE_P2_WAITING
      if user == player_a
        "#{player_b.name}'s Turn"
      else
        "Your Turn"
      end
    elsif state == STATE_COMPLETE
      winner = player_a
      winner = player_b if player_b_score > player_a_score
      "Game Complete - " + winner.name + " Won"
    end
  end

  def play(sequence,user)
    return false unless self.can_move?(user)
    player = 1
    player = 2 if self.state == STATE_P2_WAITING

    sequence.each {|s| return false if s >= SIZE*SIZE }
    sequence.each do |s|
      if !self.is_protected?(s)
        self.letters[s][self.letters[s].keys[0]] = player
      end
    end

    w = sequence.map{|s| self.letters[s].keys[0]}.join
    self.words << w

    if self.state == STATE_NEW
      self.state = STATE_WAITING
    else
      self.state = (player == 1) ? STATE_P2_WAITING : STATE_P1_WAITING
    end

    scores = [0,0,0]
    self.letters.each {|l| scores[l.values[0]] += 1 }
    self.player_a_score = scores[1]
    self.player_b_score = scores[2]

    self.save
    return true
  end

  def pretty_print
    1.upto(SIZE) do |i|
      d = letters[(i-1)*SIZE..i*SIZE-1]
      puts d.map{|a| "#{a.keys[0]} ".colorize(CONSOLE_COLOR[a.values[0]])}.join
    end
    puts "A=#{player_a_score} ".blue + "B=#{player_b_score}".red
    self.words.each_index{|i| puts "#{self.words[i]}".colorize(CONSOLE_COLOR[1+i%2])}
  end

  def is_protected?(i)
    row = i/SIZE
    col = i%SIZE
    player = self.letters[i].values[0]
    return false if player == 0

    #top
    if row > 0
      cell_id = (row-1)*SIZE + col
      return false if self.letters[cell_id].values[0] != player
    end

    #left
    if col > 0
      cell_id = row*SIZE + col - 1
      return false if self.letters[cell_id].values[0] != player
    end

    #bottom
    if row < SIZE-1
      cell_id = (row+1)*SIZE + col
      return false if self.letters[cell_id].values[0] != player
    end

    #right
    if col < SIZE-1
      cell_id = row*SIZE + col + 1
      return false if self.letters[cell_id].values[0] != player
    end
    return true
  end

  protected
  def create_letters
    self.letters = []
    self.words = []
    1.upto(SIZE * SIZE) do |i|
      b = (65+rand(26)).chr
      self.letters << {b => 0}
    end
  end
end
