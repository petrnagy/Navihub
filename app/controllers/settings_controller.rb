class SettingsController < ApplicationController

    class ImpossibleLocation < StandardError
    end

    # TODO: probably unused
    @json_response

    include ApplicationHelper

    def general
        respond_to do |format|
            msg = { :status => "error", :message => "Error!", :html => "<b>Not implemented</b>" }
            format.json { render :json => msg }
        end
    end

    def location
        if request.xhr?
            data = location_params
            if data['go']
                loc = set_location data

                respond_to do |format|
                    msg = { :status => "ok", :message => "Success!", :html => pretty_loc(loc) }
                    format.json { render :json => msg }
                end
            end
        else

        end
    end

    def profile
        if false
            render 'logged'
        else
            render 'not-logged'
        end
    end

    private

    # Smarter params filter
    def location_params
        data = Hash.new
        data['go'] = true

        interests = [ 'set', 'lat', 'lng', 'country', 'country_short', 'city', 'city2', 'street1', 'street2', 'lock' ]
        interests.each do |param|
            params.require(param) unless params.has_key?(param) && params[param].is_a?(String)
            data[param] = ( params[param].length > 0 ? params[param] : nil )
        end
        data['set'] = !! data['set']
        data['lat'] = data['lat'].to_f
        data['lng'] = data['lng'].to_f
        data['lock'] = ( data['lock'] == '1' ? true : false )
        if ! Location.possible data['lat'], data['lng']
            raise ImpossibleLocation, 'debug: ' + data.to_s
        end
        data
    end

    def set_location data
        loc = Location.create(
        user_id:        @user.id,
        latitude:       data['lat'],
        longitude:      data['lng'],
        lock:           data['lock'],
        country:        data['country'],
        country_short:  data['country_short'],
        city:           data['city'],
        city2:          data['city2'],
        street1:        data['street1'],
        street2:        data['street2'],
        active:         true
        )
        loc.save
        Location.where(user_id: @user.id).where.not(id: loc.id).update_all(active: false)
        loc
    end
end
