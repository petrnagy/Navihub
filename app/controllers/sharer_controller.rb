class SharerController < ApplicationController

    class NoDataLoaded < StandardError
    end

    def email
        parameters = email_params

        # injecting variables, can be dangerous !
        detail = DetailController.new
        detail.instance_variable_set(:@user, @user)
        detail.instance_variable_set(:@location, @location)

        data = detail.load_detail parameters['origin'], parameters['id']
        raise NoDataLoaded, 'Data: ' + {user: @user, location: @location, params: parameters}.to_s if nil == data

        res = Email.push_venue_share(parameters['email'], 'noreply@navihub.net', data)
        if res
            SharerMailer.share_via_email(parameters['email'], data).deliver
            render json: { status: 'ok' }
        else
            render status: 500
        end

    end

    private

    def email_params
        %w{id origin email}.each do |param|
            params.require(param)
            raise "'"+param+"' was not a String" unless params[param].is_a?(String)
            params[param] = Mixin.sanitize(params[param])
        end
        params.permit(:id, :origin, :email)
    end

end
