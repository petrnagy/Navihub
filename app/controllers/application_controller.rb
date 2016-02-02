class ApplicationController < ActionController::Base

  public

  class EmptySessionId < StandardError
  end
  class CouldNotSetLocation < StandardError
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
    # FIXME: Move strings to config/application.rb (but its not loaded at this stage of the application inicialization !)
    @page_name = Rails.configuration.app_name
    @page_title = Rails.configuration.app_title
    @page_desc = Rails.configuration.app_description
    @version = Rails.configuration.app_version
    @build = Rails.configuration.app_build
    # TODO: wtf is this?
    request.protocol
    request.port.blank?
    @root_url = request.base_url
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
        user = User.user_create
        sess.user_id = user.id
        cookie.user_id = user.id
      else
        user = User.user_find_by_session_user_id sess.user_id
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
    user = User.user_find_by_session_user_id sess.user_id unless user
    if user
      @user = user
    else
      @user = User.user_create
      sess.user_id = @user.id
      cookie.user_id = @user.id
    end
    sess.save; cookie.save
  end

  def init_session
    sess = Session.find_user_sess session.id

    if ! session.id
      # force session init, @see http://stackoverflow.com/questions/14665275/how-force-that-session-is-loaded
      session[:init] = true
    end

    if ! sess
      sess = Session.create_user_sess session.id
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
    @location = Location.get_user_loc @user.id
    # if I open a link from anyone else, i might not have any location assigned yet...
    # ...so we will try to set it from url params
    if @location == nil && ( params.has_key?('lat') && params.has_key?('lng') )
      lat = params['lat'].to_f
      lng = params['lng'].to_f
      if Location.possible lat, lng
        loc = Location.create(
        user_id:        @user.id,
        latitude:       lat,
        longitude:      lng,
        lock:           false,
        active:         true
        )
        loc.save
        @location = loc
      end
    end
    #raise CouldNotSetLocation if @location == nil
  end

  private

end
