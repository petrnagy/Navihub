module AccountHelper
    def self.generate_verify_hash email
        Digest::MD5.hexdigest(email + Rails.application.secrets.secret_key_base)
    end
end
