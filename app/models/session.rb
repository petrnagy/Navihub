class Session < ActiveRecord::Base
  belongs_to :user
  belongs_to :cookie

  def self.find_user_sess session_id
    return Session.find_by(sessid: session_id, active: true)
  end

  def self.create_user_sess session_id
    return Session.create(sessid: session_id, active: true, user_id: nil)
  end

end
