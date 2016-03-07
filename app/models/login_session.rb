class LoginSession < ActiveRecord::Base
    belongs_to :user
    belongs_to :cookie
    belongs_to :session

    def self.exist_for_user user_id
        row = self.select('id').where(user_id: user_id)
        .where('valid_to >= ? OR valid_to IS NULL', DateTime.now)
        .where('valid_from <= ? OR valid_from IS NULL', DateTime.now)
        .first
        if row == nil
            return false
        else
            return true
        end
    end

    def self.start user_id, session_id, cookie_id, extended = false
        self.create!(
        user_id: user_id,
        session_id: session_id,
        cookie_id: ( extended ? cookie_id : nil ),
        valid_from: nil,
        valid_to: ( extended ? DateTime.now + 1.month : DateTime.now + 1.hour ),
        extended: extended
        )
    end

end
