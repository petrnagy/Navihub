class User < ActiveRecord::Base

  has_many :cookies
  has_many :sessions
  has_many :locations
  has_many :credentials
  has_many :facebook_sessions
  has_many :twitter_sessions
  has_many :google_sessions
  has_many :favorites
  has_many :permalinks

  def self.user_create
    user = User.create(active: true)
    user.save
    user
  end

  def self.user_find_by_session_user_id session_user_id
    return User.find_by(id: session_user_id, active: true)
  end

end
