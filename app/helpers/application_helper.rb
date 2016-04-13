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

end
