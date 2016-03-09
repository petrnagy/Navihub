class Lock

    def login_with_credentials params
        username_row = Credential.where(username: params[:username]).where(active: true).first
        email_row = Credential.where(email: params[:username]).where(active: true).first
        [username_row, email_row].each do |row|
            if row != nil
                verified = verify_credentials params[:password], row[:password], row[:salt]
                return row[:user_id] if verified
                @errors = [
                    { :for => :password, :msg => 'seems to be incorrect' }
                ]
                return false
            end
        end
        @errors = [
            { :for => :username, :msg => sprintf('"%s" could not be found in our database'.html_safe, params[:username]) }
        ]
        false
    end

    def get_login_errors
        @errors
    end

    def login_with_facebook

    end

    def login_with_twitter

    end

    def login_with_google

    end

    def register_with_credentials params, user, session, cookie
        if params[:private_computer] != 1
            user = User.user_create
            session.update(user_id: user.id)
            cookie.update(user_id: user.id)
        end

        salt = BCrypt::Engine.generate_salt
        encrypted_password = BCrypt::Engine.hash_secret(params[:password], salt)
        Credential.create!(
        user_id:    user.id,
        salt:       salt,
        password:   encrypted_password,
        username:   params[:username],
        email:      ( params[:email].length > 0 ? params[:email] : nil ),
        active:     true
        )
        user
    end

    private

    def verify_credentials password1, password2, salt
        if BCrypt::Engine.hash_secret(password1, salt) === password2
            return true
        else
            return false
        end
    end

end
