class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :as => :admin
  attr_accessible :provider, :uid, :name, :email
  
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    #puts "Token : #{auth.credentials.token}"
    unless user
      user = User.create(name:auth.extra.raw_info.name,
                         provider:auth.provider,
                         uid:auth.uid,
                         email:auth.info.email,
                         #password:Devise.friendly_token[0,20]
                         )
    end
    user
  end
  def profile_picture
    "https://graph.facebook.com/#{self.uid}/picture"
  end

  def update_score
    self.update_attribute(:score, calculate_score)
  end

  def calculate_score
    (win_count*2) - loss_count
  end

  def win_count
    Game.count(:conditions => ["state = ? and ((player_a_id = ? and player_a_score > player_b_score) or (player_b_id = ? and player_b_score > player_a_score))", Game::STATE_COMPLETE, self.id, self.id])
  end

  def loss_count
    Game.count(:conditions => ["state = ? and ((player_a_id = ? and player_a_score < player_b_score) or (player_b_id = ? and player_b_score < player_a_score))", Game::STATE_COMPLETE, self.id, self.id])
  end
end
