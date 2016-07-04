# encoding: UTF-8

module ApplicationHelper

    require 'uri'
    require 'cgi'

    def javascript(*files)
        content_for(:footer_js) { javascript_include_tag(*files) }
    end

    def pretty_loc location
        return '...' if nil == location

        o = ''
        no_txt = true
        # iterate thru required fields
        %w{city city2 street1 street2}.each do |interest|
            if location[interest] != nil && location[interest].length > 0
                no_txt = false
                break
            end
        end
        if no_txt
            #o += location['latitude'].round(2).to_s + ', ' + location['longitude'].round(2).to_s
            similiar = Location.where(
                latitude: location.latitude.to_f.round(7),
                longitude: location.longitude.to_f.round(7),
            ).where.not(city: nil).order(id: :desc).first
            if similiar != nil
                o = pretty_loc similiar
            else
                o += coords_to_dms location['latitude'], location['longitude']
            end
        else
            %w{street2 street1 city2 city country}.each do |interest|
                if location[interest] != nil && location[interest].length > 0
                    o += ', ' unless 0 == o.length
                    o += location[interest]
                end
            end
            if location['country_short'] != nil && location['country_short'].length > 0
                o += ' (' + location['country_short'] + ')'
            end
        end

        o
    end

    def coords_to_dms lat, lng
        lat_direction = lat > 0.00 ? 'N' : 'S'
        lng_direction = lng > 0.00 ? 'E' : 'W'
        lat_degrees = lat.abs.floor
        lng_degrees = lng.abs.floor
        lat_decimal = (lat.abs - lat.abs.floor) * 3600
        lng_decimal = (lng.abs - lng.abs.floor) * 3600
        lat_minutes = (lat_decimal / 60).floor
        lng_minutes = (lng_decimal / 60).floor
        lat_seconds = (lat_decimal - (lat_minutes * 60)).round(0)
        lng_seconds = (lng_decimal - (lng_minutes * 60)).round(0)

        o = ''
        o += lat_degrees.to_s.rjust(2, '0') + '°' + lat_minutes.to_s.rjust(2, '0') + "'" + lat_seconds.to_s.rjust(2, '0') + '"' + lat_direction
        o += ' '
        o += lng_degrees.to_s.rjust(2, '0') + '°' + lng_minutes.to_s.rjust(2, '0') + "'" + lng_seconds.to_s.rjust(2, '0') + '"' + lng_direction
        o
    end

    def tag_search_link tag
        # FIXME: sestavit pomoci link_to a parametru
        '/search/' + CGI::escape(tag) + '/0/distance-asc/0'
    end

    def errors_for(object = nil)
        render('/common/form_errors', errors: object.errors) unless object.blank?
    end

    def show_flashes
        o = ''
        flash.each do |key, msg|
            o += render('/common/flash', msg: msg)
        end
        o.html_safe
    end

    def short_username username
        parts = username.split ' '
        if parts.length.between? 2, 3
            o = ''
            parts.each do |part|
                o += part.slice(0, 1).capitalize
            end
            return o
        else
            return username.slice(0, 1).capitalize + '..' + username.slice(-1, 1).capitalize
        end
    end

    def method_missing(name, *args, &block)
        if /^signin_with_(\S*)$/.match(name.to_s)
            "/auth/#{$1}"
        else
            super
        end
    end

    def logged_in
        @logged_in
    end

    def login_method
        if @credentials.is_a? Credential
            'local'
        elsif @credentials.is_a? ProviderCredential
            'provider'
        else
            nil
        end
    end

    def login_provider
        @credentials.provider
    end

    def username
        if 'local' == login_method
            @credentials.username
        elsif 'provider' == login_method
            @credentials.name
        else
            nil
        end
    end

    def user_email
        if 'local' == login_method
            @credentials.email
        elsif 'provider' == login_method
            nil
        else
            nil
        end
    end

    def user_session_expiration
        sess = LoginSession.get_for_user @user.id, @session.id, @cookie.id
        sess.valid_to
    end

    def is_bot
        return !! (request.env['HTTP_USER_AGENT'] =~ /bot|crawl|slurp|spider/i)
    end

    protected

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
        @request_location = nil; @request_ll = nil;
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
        unless @request_location == nil
            @request_ll = @request_location.latitude.to_s + ',' + @request_location.longitude.to_s
        end
    end

end
