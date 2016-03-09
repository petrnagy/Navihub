class AccountController < ApplicationController

    require 'digest/md5'

    def index
        @page_title = 'Account management'
        @login_form = Credential.new
        @registration_form = Credential.new
        if @logged_in
            render 'manage'
        else
            render 'not_logged'
        end
    end

    def create
        redirect_to controller: 'homepage' if @logged_in

        @page_title = 'Account creation'
        @registration_form = Credential.new
    end

    def process_create
        redirect_to controller: 'homepage' if @logged_in

        parameters = create_params
        @registration_form = Credential.new(parameters)
        if @registration_form.valid?
            lock = Lock.new
            @user = lock.register_with_credentials parameters, @user, @session, @cookie
            # FIXME: @user, @session a @cookie nejsou po registraci aktualni
            LoginSession.start @user.id, @session.id, @cookie.id, (parameters[:private_computer] == 1 ? true : false)
            flash[:new_registration_msg] = { :type => 'success', :text => 'You are now registered (and logged in) with username <b>'+parameters[:username]+'</b>. Enjoy !' }
            redirect_to controller: 'homepage'
        else
            @page_title = 'Account creation - errors found'
            render 'create'
        end
    end

    def verify
    end

    def login
        redirect_to controller: 'homepage' if @logged_in

        @page_title = 'Log in page'
        @login_form = Credential.new
    end

    def process_login
        redirect_to controller: 'homepage' if @logged_in

        @page_title = 'Log in page'
        parameters = process_login_params
        @login_form = Credential.new(parameters)
        if parameters[:username].to_s != '' && parameters[:password].to_s != ''
            lock = Lock.new
            new_user_id = lock.login_with_credentials(parameters)
            if new_user_id
                @user = User.find_by(id: new_user_id)
                @session.user_id = new_user_id; @session.save
                @cookie.user_id = new_user_id; @cookie.save
                LoginSession.start @user.id, @session.id, @cookie.id, (parameters[:remember] == 1 ? true : false)
                flash[:new_login_msg] = { :type => 'success', :text => 'You are now logged in. Enjoy !' }
                redirect_to controller: 'homepage'
            else
                @login_errors = lock.get_login_errors
                if @login_errors != nil
                    @login_errors.each do |error|
                        @login_form.errors.add(error[:for], error[:msg])
                    end
                end
                render 'login'
            end
        else
            @login_form.errors.add(:username, 'can\'t be blank, please fill in your username or e-mail address') if parameters[:username].to_s == ''
            @login_form.errors.add(:password, 'can\'t be blank') if parameters[:password].to_s == ''
            @page_title = 'Log in page, errors found'
            render 'login'
        end
    end

    def logout
        if @logged_in
            LoginSession.destroy_for_user @user.id, @session.id, @cookie.id
            flash[:logout_msg] = { :type => 'info', :text => 'You have been logged out. See you soon...?' }
        end
        redirect_to controller: 'homepage'
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

end
