class ApplicationController < ActionController::Base

    include ApplicationHelper

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
        @yandex_site_verification   = Rails.configuration.yandex_site_verification
        @page_author                = Rails.configuration.app_author
        @version                    = Rails.configuration.app_version
        @build                      = Rails.configuration.app_build
        @root_url                   = request.base_url
    end

end
