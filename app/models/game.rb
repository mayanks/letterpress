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

  @error = ""
  def error
    @error
  end
  def error=(e)
    @error = e
  end
      
  @@VALID_WORDS = {}
  @@CANDIDATES = []
  def self.VALID_WORDS
    @@VALID_WORDS
  end
  def self.candidates
    @@CANDIDATES
  end

  def self.setup(file)
    # Valid words are looked up against the dictionary called TWL06 provided by internet scrabbles club 
    # http://www.isc.ro/en/commands/lists.html
    f = File.read(file)
    f.split.each{|w| Game.VALID_WORDS[w] = true}
    #f.split.each{|w| Rails.cache.write(w,true)}

    # Frequency distribution of letters are according to letters available in Scrabble. This ensures that a playable random
    # board is presented every single time. http://en.wikipedia.org/wiki/Scrabble_letter_distributions
    letter_frequency = { "A"=>9,"B"=>2,	"C"=>2, "D"=>4, "E"=>12,	"F"=>2, "G"=>3, "H"=>2, "I"=>9, "J"=>1, "K"=>1, "L"=>4, "M"=>2, "N"=>6, "O"=>8, "P"=>2, "Q"=>1, "R"=>6, "S"=>4, "T"=>6, "U"=>4, "V"=>2, "W"=>2, "X"=>1, "Y"=>2, "Z"=>1	}
    letter_frequency.each do |c,f|
      1.upto(f) {|i| Game.candidates << c}
    end
  end
  
  def valid_word?(w)
    Game.VALID_WORDS[w]
    #Rails.cache.read(w)
  end
  
  def can_move?(user)
    return true if self.state == STATE_NEW and user == player_a
    return true if self.state == STATE_P1_WAITING and user == player_a
    return true if self.state == STATE_P2_WAITING and user == player_b
    return false
  end

  def should_wait?(user)
    (user) and 
     ((state == STATE_P1_WAITING and user == player_b) or
      (state == STATE_P2_WAITING and user == player_a))
  end
  
  def status_string(user)
    if state == STATE_NEW
      "New Game"
    elsif state == STATE_WAITING
      "Waiting for an opponent to join"
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
      score_s = "#{player_a_score} - #{player_b_score}"
      if player_b_score > player_a_score
        winner = player_b
        score_s = "#{player_b_score} - #{player_a_score}"
      end
      "Game Complete - " + winner.name + " Won " + score_s
    end
  end

  def play(sequence,user)
    unless self.can_move?(user)
      self.error = "Sorry, not your turn"
      return false
    end
    
    player = 1
    player = 2 if self.state == STATE_P2_WAITING

    sequence.each {|s| return false if s >= SIZE*SIZE }

    word = sequence.map{|s| self.letters[s].keys[0]}.join
    unless valid_word?(word)
      self.error = "Whoops!! #{word} is not present in my dictionary."
      self.error += "Dictionary:#{Game.VALID_WORDS.keys.length}" if Rails.env == 'development'
      return false
    end
    
    if self.words.index(word)
      self.error = "Darn!! did not realize #{word} is already used?"
      return false
    end
    
    self.words << word
    
    sequence.each do |s|
      if !self.is_protected?(s)
        self.letters[s][self.letters[s].keys[0]] = player
      end
    end

    if self.state == STATE_NEW
      self.state = STATE_WAITING
    else
      self.state = (player == 1) ? STATE_P2_WAITING : STATE_P1_WAITING
    end

    scores = [0,0,0]
    self.letters.each {|l| scores[l.values[0]] += 1 }
    self.player_a_score = scores[1]
    self.player_b_score = scores[2]
    
    # Game is complete if all tiles are colored
    self.state = STATE_COMPLETE if scores[0] == 0
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

  def notification_msg(u)
    return nil if u != player_a and u != player_b
    opponent = (player_a == u) ? player_b : player_a
    if state == STATE_P1_WAITING or state == STATE_P2_WAITING
      msg = "@[#{opponent.uid}] has played #{self.words.last}. It's your move now"
    elsif state == STATE_COMPLETE
      winner = player_a
      score_s = "#{player_a_score} - #{player_b_score}"
      if player_b_score > player_a_score
        winner = player_b
        score_s = "#{player_b_score} - #{player_a_score}"
      end
      if winner == u
        msg = "Congratulations!! You defeated @[#{opponent.uid}]. Score #{score_s}"
      else
        msg = "Hard luck. @[#{opponent.uid}] defeated you. Score #{score_s}"
      end
      return msg
    end
  end

  protected
  def create_letters
    self.letters = Game.candidates.shuffle[0..SIZE*SIZE-1].map{|a| {a=>0}}
    self.words = []
  end

  def create_letters_old
    self.letters = []
    self.words = []
    1.upto(SIZE * SIZE) do |i|
      b = (65+rand(26)).chr
      self.letters << {b => 0}
    end
  end
end
