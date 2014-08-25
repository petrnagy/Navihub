class Session < ActiveRecord::Base
  belongs_to :user_id
  belongs_to :cookie_id
end
