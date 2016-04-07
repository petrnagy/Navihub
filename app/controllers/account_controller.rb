class AccountController < ApplicationController

    require 'digest/md5'

    include ApplicationHelper

    def index
        @page_title = 'Account management'
        @login_form = Credential.new
        @registration_form = Credential.new
        if logged_in
            render 'manage'
        else
            render 'not_logged'
        end
    end

    def create
        return redirect_to controller: 'homepage' if logged_in

        @page_title = 'Account creation'
        @registration_form = Credential.new
    end

    def process_create
        return redirect_to controller: 'homepage' if logged_in

        parameters = create_params
        @registration_form = Credential.new(parameters)
        if @registration_form.valid?
            lock = Lock.new
            result = lock.register_with_credentials parameters, @user, @session, @cookie
            @user = result[:user]
            # FIXME: wrong number of arguments !
            LoginSession.start(
            @user.id,
            @session.id,
            @cookie.id,
            (parameters[:private_computer] == 1 ? true : false),
            result[:credentials].id,
            nil
            )
            if parameters[:email].to_s != ''
                AccountMailer.send_new_acc_email(parameters[:email], parameters[:username], @user.id).deliver
            end
            flash[:new_registration_msg] = { :type => 'success', :text => 'You are now registered (and logged in) with username <b>'+parameters[:username]+'</b>. Enjoy !' }
            redirect_to controller: 'homepage'
        else
            @page_title = 'Account creation - errors found'
            render 'create'
        end
    end

    def verify
        parameters = verify_params
        row = Credential.where(username: parameters[:username], active: true).first
        unless row == nil or row.email == nil
            hash = AccountHelper::generate_verify_hash(row.email)
            if hash == parameters[:hash]
                row.update!(email_verified: true)
                flash[:verification] = { :type => 'success', :text => 'E-mail address <b>' + row.email + '</b> has been successfully verified, thank you !' }
                return redirect_to controller: 'homepage'
            end
        end
        flash[:verification] = { :type => 'warning', :text => 'We could not verify your e-mail address. Please contact us, or try again later.' }
        redirect_to controller: 'homepage'
    end

    def login
        return redirect_to controller: 'homepage' if logged_in

        @page_title = 'Log in page'
        @login_form = Credential.new
    end

    def process_login
        return redirect_to controller: 'homepage' if logged_in

        @page_title = 'Log in page'
        parameters = process_login_params
        @login_form = Credential.new(parameters)
        if parameters[:username].to_s != '' && parameters[:password].to_s != ''
            lock = Lock.new
            credentials = lock.login_with_credentials(parameters)
            if credentials
                @user = User.find_by(id: credentials[:user_id])
                @session.user_id = credentials[:user_id]; @session.save
                @cookie.user_id = credentials[:user_id]; @cookie.save
                remember = (parameters[:remember] == 1 ? true : false)
                LoginSession.start @user.id, @session.id, @cookie.id, remember, credentials[:id], nil
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
        if logged_in
            LoginSession.destroy_for_user @user.id, @session.id, @cookie.id
            #ProviderCredential.destroy_for_user @user.id, @session.id, @cookie.id
            @session.user_id = nil; @session.save
            @cookie.user_id = nil; @cookie.save
            flash[:logout_msg] = { :type => 'info', :text => 'You have been logged out. See you soon...?' }
        end
        redirect_to controller: 'homepage'
    end

    def manage
        return redirect_to controller: 'homepage' if not logged_in
    end

    def update
        return redirect_to controller: 'homepage' if not logged_in
        flash[:not_implemented] = { :type => 'warning', :text => 'We are sorry, but this function is not currently available. Please try again later.' }
        redirect_to controller: 'account', action: 'manage'
    end

    def close
        return redirect_to controller: 'homepage' if not logged_in
        flash[:not_implemented] = { :type => 'warning', :text => 'We are sorry, but this function is not currently available. Please try again later.' }
        redirect_to controller: 'account', action: 'manage'
    end

    def omniauth
        if logged_in
            flash[:provider_msg] = { :type => 'info', :text => 'Before using the ' + auth_hash.provider.capitalize + ' login, you need to log out first.' }
            return redirect_to controller: 'homepage'
        end

        credentials = ProviderCredential.find_or_create_from_auth_hash(auth_hash, @user.id)
        @user.id = credentials.user_id
        @session.user_id = @user.id; @session.save
        @cookie.user_id = @user.id; @cookie.save
        LoginSession.start @user.id, @session.id, @cookie.id, true, nil, credentials.id
        flash[:provider_msg] = { :type => 'success', :text => 'You are now logged in via ' + auth_hash.provider.capitalize + ' as <b>' + credentials.name.to_s + '</b>, enjoy !' }
        redirect_to controller: 'homepage'
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

    def verify_params
        params.require(:username)
        params.require(:hash)
        params.permit(:username, :hash)
    end

    def auth_hash
        request.env['omniauth.auth']
    end

end
