class AccountController < ApplicationController

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
          # TODO: create user
          redirect_to action: 'created'
      else
          @page_title = 'Account creation - errors found'
          render 'create'
      end
  end

  def created
      # TODO: IF new user then...
      @page_title = 'Account created'
      render 'created'
  end

  def verify
  end

  def login
      @page_title = 'Log in page'
      @login_form = Credential.new
  end

  def process_login
      @page_title = 'Log in page'

      @login_form = Credential.new(parameters)
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

  def login_params
      params.require(:credential)
      .permit(:username, :password, :remember)
  end

end
