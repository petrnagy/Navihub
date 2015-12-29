class Cookie < ActiveRecord::Base
  has_many :sessions
  belongs_to :user
end
