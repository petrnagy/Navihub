class User < ActiveRecord::Base

  has_many :cookies
  has_many :sessions
  has_many :locations
  has_many :credentials
  has_many :facebook_sessions
  has_many :twitter_sessions
  has_many :google_sessions
  has_many :permalinks

  public

  protected

  private

end
