class FavoritesController < ApplicationController

    def create
        if request.xhr?
            parameters = create_params
            if @user && @user.id != nil
                if ! Favorite.find_by(user_id: @user.id, venue_origin: parameters['origin'], venue_id: parameters['id'])
                    favorite = Favorite.new
                    favorite.user_id = @user.id
                    favorite.venue_id = parameters['id']
                    favorite.venue_origin = parameters['origin']
                    # FIXME: DANGEROUS construct ! ! ! ! ! ! ! !
                    favorite.yield = parameters['yield']
                    favorite.save
                end
                return render json: { status: 'OK', id: nil }
            end
        end
        render json: { status: 'ERROR', id: nil }, :status => 400
    end

    def delete
        parameters = delete_params
        if request.xhr?
            if @user && @user.id != nil
                favorite = Favorite.find_by(user_id: @user.id, venue_origin: parameters['origin'], venue_id: parameters['id'])
                if favorite
                    favorite.delete
                end
                return render json: { status: 'OK', id: nil }
            end
        end
        render json: { status: 'ERROR', id: nil }, :status => 400
    end

    private

    def create_params
        params.require(:origin)
        params.require(:id)
        params.require(:yield)
        params.permit(:id, :origin, :yield)
    end

    def delete_params
        params.require(:origin)
        params.require(:id)
        params.permit(:id, :origin)
    end

end
