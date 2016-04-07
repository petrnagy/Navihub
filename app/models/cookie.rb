class Cookie < ActiveRecord::Base
  has_many :sessions
  has_many :login_sessions
  belongs_to :user
end
