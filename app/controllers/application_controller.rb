class ApplicationController < ActionController::Base

  public

  class EmptySessionId < StandardError
  end

  @failsafe;

  protect_from_forgery with: :exception

  before_filter :init

  protected

  @user; @location

  def init
    init_html_variables
    init_user
    init_location
    @failsafe = false
  end

  def init_html_variables
    @page_lang_cls = determine_lang
    @page_robots = Rails.env.production? ? 'index, follow' : 'noindex, nofollow'
    @device_cls = determine_device
    @is_logged_in_cls = determine_login_status
  end

  def determine_lang # @todo lang
    'en'
  end

  def determine_device # https://github.com/benlangfeld/mobile-fu
    'desktop'
  end

  def determine_login_status # not implemented yet
    'not-logged-in'
  end

  def init_user
    user = nil
    sess = init_session
    cookie = init_cookie
    if sess.user_id == cookie.user_id
      if sess.user_id == nil
        user = User.create(active: true); user.save
        sess.user_id = user.id
        cookie.user_id = user.id
      else
        user = User.find_by(id: sess.user_id, active: true)
      end
    else
      if sess.user_id && cookie.user_id
        cookie.user_id = sess.user_id
      else
        if sess.user_id == nil
          sess.user_id = cookie.user_id
        else
          cookie.user_id = sess.user_id
        end
      end
    end
    user = User.find_by(id: sess.user_id, active: true) unless user
    if user
      @user = user
    else
      @user = User.create(active: true); @user.save
      sess.user_id = @user.id
      cookie.user_id = @user.id
    end
    sess.save; cookie.save
  end

  def init_session
    sess = Session.find_by(sessid: session.id, active: true)

    if ! session.id
      # force session init, @see http://stackoverflow.com/questions/14665275/how-force-that-session-is-loaded
      session[:init] = true
    end

    if ! sess
      sess = Session.create(sessid: session.id, active: true, user_id: nil)
    elsif ! session.id
      raise EmptySessionId
    end
    sess
  end

  def init_cookie
    create = false
    if cookies[:navihub_id] == nil
      create = true
    else
      cookie = Cookie.find_by(cookie: cookies[:navihub_id], active: true)
      create = true unless cookie
    end
    if create
      cookies[:navihub_id] = { :value => SecureRandom.base64(32), :httponly => true }
      cookie = Cookie.create(cookie: cookies[:navihub_id], active: true, user_id: nil)
    end
    cookie
  end

  def init_location
    @location = Location.where(user_id: @user.id, active: true).order('id DESC').first
  end

  private

end
