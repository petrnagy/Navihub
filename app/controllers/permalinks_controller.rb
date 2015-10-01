class PermalinksController < ApplicationController

    require 'digest/md5'

    def create
        if request.xhr?
            if params.has_key?('origin') && params.has_key?('id')
                detail = DetailController.new

                # injecting variables, can be dangerous !
                detail.instance_variable_set(:@user, @user)
                detail.instance_variable_set(:@location, @location)

                data = detail.loadDetail params['origin'], params['id']

                if data && @user.id != nil
                    data_yield = YAML::dump data
                    key = Digest::MD5.hexdigest(data_yield)
                    if ! Permalink.find_by(permalink_id: key)
                        permalink = Permalink.new
                        permalink.yield = data_yield
                        permalink.permalink_id = key
                        permalink.venue_origin = params['origin']
                        permalink.venue_id = params['id']
                        permalink.user_id = @user.id
                        permalink.save
                    end
                    return render json: { status: 'OK', id: key }
                end
            end
        end
        render json: { status: 'ERROR', id: nil }, :status => 400
    end

end
