require 'base64'
require 'json'

class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  before_filter :check_facebook_login

  def check_facebook_login
    if Rails.env == 'development'
      u = User.find(1)
      sign_in(u, :event => :authentication)
    end
    if params[:signed_request]
      (encoded_sig,encoded_payload) = params[:signed_request].split(/\./)
      data = JSON.parse(base64_url_decode(encoded_payload))
      if data["user_id"]
        u = User.find_by_uid(data["user_id"])
        if u 
          sign_in(u, :event => :authentication)
        end
      end
    end
  end

  def base64_url_decode(str)
    str += '=' * (4 - str.length.modulo(4))
    Base64.decode64(str.gsub("-", "+").gsub("_", "/"))
  end
end
