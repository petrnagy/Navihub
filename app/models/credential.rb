class Credential < ActiveRecord::Base
  belongs_to :user

  attr_accessor :private_computer

  EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i
  USERNAME_REGEX = /\A[A-Z0-9\_\-]+\z/i

  validates :password, confirmation: true, :presence => true, :uniqueness => true, :length => { :in => 3..30 }
  validates :email, allow_blank: true, :uniqueness => true, :format => EMAIL_REGEX
  validates :username, :presence => true, :uniqueness => true, :length => { :in => 3..20 }, :format => USERNAME_REGEX

end
