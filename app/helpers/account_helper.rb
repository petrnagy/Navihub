module AccountHelper
    def self.generate_verify_hash recipient, username, user_id
        Digest::MD5.hexdigest([recipient, username, user_id].to_s)
    end
end
