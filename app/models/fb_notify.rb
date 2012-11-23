require 'net/http'
require 'net/https'

class FbNotify < ActiveRecord::Base
  belongs_to :game
  belongs_to :user
  attr_accessible :game_id, :user_id, :state, :notified, :notification_status, :notification_response

  APP_ACCESS_TOKEN = "112948842198972|1UqmirwkEKpjm6XJJbEE9UaZasA"

  #
  def notify
    if ((game.state == state) and (notified == false))
      msg = game.notification_msg(user)
      if msg
        msg = CGI.escape(msg)
        href = CGI.escape("games/#{game.id}")
        uri = URI.parse("https://graph.facebook.com/")
        uri_path = "/#{user.uid}/notifications?access_token=#{APP_ACCESS_TOKEN}&template=#{msg}&href=#{href}"
        https = Net::HTTP.new(uri.host,uri.port)
        https.use_ssl = true
        begin 
          req = Net::HTTP::Post.new(uri_path)
          res = https.request(req)
          self.notification_response = res.body
          self.notification_status = res.code.to_i
        rescue => ex
          self.notification_status = 500
          puts "Failed to post to facebook"
        end
      end
      self.notified = true
      self.save
    end
  end
end
