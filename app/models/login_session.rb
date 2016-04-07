class LoginSession < ActiveRecord::Base
    belongs_to :user
    belongs_to :cookie
    belongs_to :session
    belongs_to :credential
    belongs_to :provider_credential

    def self.exist_for_user user_id, session_id, cookie_id
        row = self.get_for_user user_id, session_id, cookie_id
        if row == nil
            return false
        else
            return true
        end
    end

    def self.start user_id, session_id, cookie_id, extended = false, credentials_id, provider_credentials_id
        self.create!(
        user_id: user_id,
        session_id: session_id,
        cookie_id: ( extended ? cookie_id : nil ),
        valid_from: nil,
        valid_to: ( extended ? DateTime.now + 1.month : DateTime.now + 1.hour ),
        extended: extended,
        credentials_id: credentials_id,
        provider_credentials_id: provider_credentials_id
        )
    end

    def self.extend_for_user user_id, session_id, cookie_id
        row = self.get_for_user user_id, session_id, cookie_id
        if row.extended == true
            timespan = 1.month
        else
            timespan = 1.hour
        end
        row.update(valid_to: DateTime.now + timespan)
    end

    def self.destroy_for_user user_id, session_id, cookie_id
        self.where(user_id: user_id, session_id: session_id).destroy_all
        self.where(user_id: user_id, cookie_id: cookie_id).destroy_all
    end

    private

    def self.get_for_user user_id, session_id, cookie_id
        self.where(user_id: user_id)
        .where('session_id = ? OR cookie_id = ?', session_id, cookie_id)
        .where('valid_to >= ? OR valid_to IS NULL', DateTime.now)
        .where('valid_from <= ? OR valid_from IS NULL', DateTime.now)
        .first
    end

end
