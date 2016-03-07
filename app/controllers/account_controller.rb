class AccountController < ApplicationController

    require 'digest/md5'

    def index
        @page_title = 'Account management'
        @login_form = Credential.new
        @registration_form = Credential.new
        render 'not_logged'
    end

    def create
        @page_title = 'Account creation'
        @registration_form = Credential.new
    end

    def process_create
        parameters = create_params
        @registration_form = Credential.new(parameters)
        if @registration_form.valid?
            @user = Lock.register_with_credentials parameters, @user, @session, @cookie
            # FIXME: @user, @session a @cookie nejsou po registraci aktualni
            LoginSession.start @user.id, @session.id, @cookie.id, (parameters[:private_computer] == 1 ? true : false)
            hash = generate_created_hash parameters[:username]
            redirect_to action: 'created', username: parameters[:username], created_hash: hash
        else
            @page_title = 'Account creation - errors found'
            render 'create'
        end
    end

    def created
        parameters = created_params
        hash = generate_created_hash parameters[:username]
        if hash == parameters[:created_hash]
            @page_title = 'Account created'
            @username = parameters[:username]
            render 'created'
        else
            redirect_to controller: 'homepage'
        end

    end

    def verify
    end

    def login
        @page_title = 'Log in page'
        @login_form = Credential.new
    end

    def process_login
        @page_title = 'Log in page'
        parameters = process_login_params
        @login_form = Credential.new(parameters)
        if @login_form.valid?
            # TODO: log user in...
            lock = Lock.new
            logged_in = lock.login_with_credentials(parameters)
            if logged_in
                flash[:new_login_msg] = { :type => 'success', :text => 'You are now logged in. Enjoy !' }
                redirect_to controller: 'homepage'
            else
                # TODO: set errors...
                render 'login'
            end
        else
            @page_title = 'Log in page, errors found'
            render 'login'
        end
    end

    def logout
    end

    def process_logout
    end

    def manage
    end

    def close
    end

    def google
    end

    def facebook
    end

    def twitter
    end

    private

    def create_params
        params.require(:credential)
        .permit(:username, :email, :password, :password_confirmation, :private_computer)
    end

    def process_login_params
        params.require(:credential)
        .permit(:username, :password, :remember)
    end

    def created_params
        params.require(:username)
        params.require(:created_hash)
        params.permit(:username, :created_hash)
    end

    def generate_created_hash username
        Digest::MD5.hexdigest(username + '@' + Date.today.to_s)
    end

end
