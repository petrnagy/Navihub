class Credential < ActiveRecord::Base
    belongs_to :user

    attr_accessor :private_computer, :remember

    EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i
    USERNAME_REGEX = /\A[A-Z0-9\_\-]+\z/i

    validates :password, confirmation: true, :presence => true, :uniqueness => true, :length => { :in => 8..255 }
    validates :email, allow_blank: true, :uniqueness => true, :format => EMAIL_REGEX
    validates :username, :presence => true, :uniqueness => true, :length => { :in => 3..30 }, :format => USERNAME_REGEX

    def self.exist_for_user user_id
        row = self.select('id').where(user_id: user_id, active: true).first
        if row == nil
            return false
        else
            return true
        end
    end

    def self.get_for_user user_id
        self.select('username, email').where(user_id: user_id, active: true).first
    end

end
