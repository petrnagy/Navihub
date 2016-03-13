class ApplicationController < ActionController::Base

    public

    class EmptySessionId < StandardError
    end
    class CouldNotSetLocation < StandardError
    end

    protect_from_forgery with: :exception
    before_filter :init

    protected

    @credentials = nil, @session = nil, @cookie = nil, @logged_in = nil

    def init
        init_user
        init_location
        init_html_variables
    end

    def init_html_variables
        # BEWARE! The config is loaded only once, during webserver startup
        @page_lang_cls              = determine_lang
        @page_robots                = Rails.env.production? ? 'index, follow' : 'noindex, nofollow'
        @device_cls                 = determine_device
        @is_logged_in_cls           = determine_login_status
        @page_name                  = Rails.configuration.app_name
        @page_title                 = Rails.configuration.app_title
        @page_desc                  = Rails.configuration.app_description
        @page_keywords              = Rails.configuration.app_keywords
        @google_site_verification   = Rails.configuration.google_site_verification
        @ms_site_verification       = Rails.configuration.ms_site_verification
        @page_author                = Rails.configuration.app_author
        @version                    = Rails.configuration.app_version
        @build                      = Rails.configuration.app_build
        @root_url                   = request.base_url
    end

    def determine_lang
        'en'
    end

    def determine_device # https://github.com/benlangfeld/mobile-fu
        'desktop'
    end

    def determine_login_status # not implemented yet
        @logged_in ? 'logged-in' : 'not-logged-in'
    end

    def init_user
        logged_in    = false
        user         = nil
        credentials  = nil
        sess         = init_session
        cookie       = init_cookie

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
            # we have a returning user
            if Credential.exist_for_user user.id
                # current user is a registered user
                if LoginSession.exist_for_user user.id, sess.id, cookie.id
                    # login session is active, the user is logged in
                    credentials = Credential.get_for_user user.id
                    @user = user
                    logged_in = true
                    LoginSession.extend_for_user user.id, sess.id, cookie.id
                else
                    # login session expired, create new anonymous user
                    @user = User.user_create
                    sess.user_id = @user.id
                    cookie.user_id = @user.id
                end
            elsif ProviderCredential.exist_for_user user.id
                # current user was/is logged using fb|tw|g+
                if LoginSession.exist_for_user user.id, sess.id, cookie.id
                    # provider login session is active, user is logged in
                    credentials = ProviderCredential.get_for_user user.id, sess.id, cookie.id
                    logged_in = true
                    @user = user
                    LoginSession.extend_for_user user.id, sess.id, cookie.id
                else
                    # provider session expired
                    @user = User.user_create
                    sess.user_id = @user.id
                    cookie.user_id = @user.id
                end
            else
                @user = user
            end
        else
            # we have a first-time visitor
            @user = User.user_create
            sess.user_id = @user.id
            cookie.user_id = @user.id
        end
        sess.save; cookie.save
        @credentials    = credentials
        @session        = sess
        @cookie         = cookie
        @logged_in      = logged_in
    end

    def init_session
        if ! session.id
            # force session init, @see http://stackoverflow.com/questions/14665275/how-force-that-session-is-loaded
            session[:init] = true
        end

        sess = Session.find_user_sess session.id

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
    end

end
