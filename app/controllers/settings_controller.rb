class SettingsController < ApplicationController

    class ImpossibleLocation < StandardError
    end
    class ParamWasNotString < StandardError
    end

    include ApplicationHelper

    def general
        respond_to do |format|
            msg = { :status => "error", :message => "Error!", :html => "<b>Not implemented</b>" }
            format.json { render :json => msg }
        end
    end

    def location

    end

    def location_set
        if request.xhr?
            data = location_params
            if data['go']
                loc = set_location data

                respond_to do |format|
                    msg = { :status => "ok", :message => "Success!", :html => pretty_loc(loc) }
                    format.json { render :json => msg }
                end
            end
        end
    end

    private

    # Smarter params filter
    def location_params
        data = Hash.new
        data['go'] = true

        interests = %w{set lat lng country country_short city city2 street1 street2 lock}
        interests.each do |param|
            params.require(param) unless params.has_key?(param) && params[param].is_a?(String)
            data[param] = ( params[param].length > 0 ? Mixin.sanitize(params[param]) : nil )
        end
        data['set'] = data['set'] == 1 ? true : false
        data['lat'] = data['lat'].to_f
        data['lng'] = data['lng'].to_f
        data['lock'] = ( data['lock'] == '1' ? true : false )
        if ! Location.possible data['lat'], data['lng']
            raise ImpossibleLocation, 'debug: ' + data.to_s
        end
        data
    end

    def set_location data
        Location.update_user_loc data, @user.id
    end
end
