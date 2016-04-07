class ProviderCredential < ActiveRecord::Base

    belongs_to :user
    has_many :login_sessions

    def self.find_or_create_from_auth_hash auth_hash, user_id
        row = where(provider: auth_hash.provider, uid: auth_hash.uid).first_or_create!

        row.user_id = user_id if row.user_id == nil
        row.name = auth_hash.info.name
        row.profile_image = auth_hash.info.image
        row.token = auth_hash.credentials.token
        row.secret = auth_hash.credentials.secret
        row.active = true

        row.save
        row
    end

    def self.exist_for_user user_id
        row = self.select('id').where(user_id: user_id, active: true).first
        if row == nil
            return false
        else
            return true
        end
    end

    def self.get id
        self.where(id: id, active: true).first
    end

    #
    # def self.destroy_for_user user_id, session_id, cookie_id
    #     self.where(user_id: user_id, session_id: session_id).destroy_all
    #     self.where(user_id: user_id, cookie_id: cookie_id).destroy_all
    # end
    #
    # private
    #
    def self.get_for_user user_id
        self.where(user_id: user_id, active: true).first
    end

end
