class SharerController < ApplicationController

    def email
        parameters = email_params
        render json: parameters
    end

    private

    def email_params
        params.require(:id)
        params.require(:origin)
        params.require(:email)
        params.permit(:id, :origin, :email)
    end

end
