class ApplicationController < ActionController::Base

    public

    class EmptySessionId < StandardError
    end
    class CouldNotSetLocation < StandardError
    end

    protect_from_forgery with: :exception
    before_filter :init

    #continue to use rescue_from in the same way as before
    unless Rails.application.config.consider_all_requests_local
        rescue_from Exception, :with => :render_error
        rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
        rescue_from ActionController::RoutingError, :with => :render_not_found
        rescue_from ActionController::ParameterMissing, with: :render_bad_request
    end

    #called by last route matching unmatched routes.  Raises RoutingError which will be rescued from in the same way as other exceptions.
    def raise_not_found!
        raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
    end

    #render 500 error (internal server error)
    def render_error(e)
        render :template => "errors/500", :status => 500
    end

    #render 404 error (not found)
    def render_not_found(e)
        render :template => "errors/404", :status => 404
    end

    #render 400 error (bad request)
    def render_bad_request(e)
        render :template => "errors/400", :status => 400
    end

    protected

    @credentials = nil, @session = nil, @cookie = nil, @logged_in = nil

    def init
        init_user
        init_location
        init_html_variables
        extend_sitemap
    end

    def init_html_variables
        # BEWARE! The config is loaded only once, during webserver startup
        @page_lang_cls              = determine_lang
        @page_robots                = Rails.env.development? ? 'noindex, nofollow' : 'index, follow'
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

    # sets @credentials, @session, @cookie and @logged_in
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
            elsif LoginSession.exist_for_user user.id, sess.id, cookie.id
                # current user was/is logged using fb|tw|g+
                session = LoginSession.get_for_user user.id, sess.id, cookie.id
                if session.provider_credentials_id != nil
                    # provider login session is active, user is logged in
                    credentials = ProviderCredential.get session.provider_credentials_id
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

    # creates and returns session instance
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

    # creates and returns cookie instance
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

    # sets @location and @request_location
    def init_location
        @location = Location.get_user_loc @user.id
        @request_location = nil
        # if I open a link from anyone else, i might not have any location assigned yet...
        # ...so we will try to set it from url params
        if params.has_key?('lat') && params.has_key?('lng')
            lat = params['lat'].to_f
            lng = params['lng'].to_f
            if Location.possible lat, lng
                @request_location = Location.new(
                user_id:        @user.id,
                latitude:       lat,
                longitude:      lng,
                lock:           false,
                active:         true
                )
            end
        end

        if @location == nil && @request_location != nil
            @location = @request_location
            @location.save
        elsif @request_location == nil && @location != nil
            @request_location = @location
        elsif @request_location != nil && @location != nil
            if @request_location.latitude == @location.latitude && @request_location.longitude == @location.longitude
                @request_location = @location
            end
        end
    end

    def extend_sitemap
        url = request.path
        controller = params[:controller]
        save = false
        return unless %w{search detail}.include? controller
        return if url == '/' + controller.to_s

        case controller
        when 'search'
            if url =~ /^\/#{controller}.+/
                save = true
                if request.fullpath =~ /\?term=.+/
                    url = url + '?term=' + params[:term]
                end
            end
        when 'detail'
            save = true
            if request.fullpath =~ /\?id=.+/
                url = request.fullpath
            end
        end

        Sitemap.add(url, controller) if save
    end

end
