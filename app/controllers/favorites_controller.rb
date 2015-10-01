class FavoritesController < ApplicationController

  def create
      if request.xhr?
          if params.has_key?('origin') && params.has_key?('id') && params.has_key?('yield')
              if @user && @user.id != nil
                  if ! Favorite.find_by(user_id: @user.id, venue_origin: params['origin'], venue_id: params['id'])
                      favorite = Favorite.new
                      favorite.user_id = @user.id
                      favorite.venue_id = params['id']
                      favorite.venue_origin = params['origin']
                      # FIXME: DANGEROUS construct ! ! ! ! ! ! ! !
                      favorite.yield = params['yield']
                      favorite.save
                  end
                  return render json: { status: 'OK', id: nil }
              end
          end
      end
      render json: { status: 'ERROR', id: nil }, :status => 400
  end

  def delete
      if request.xhr?
          if params.has_key?('origin') && params.has_key?('id')
              if @user && @user.id != nil
                  favorite = Favorite.find_by(user_id: @user.id, venue_origin: params['origin'], venue_id: params['id'])
                  if favorite
                      favorite.delete
                  end
                  return render json: { status: 'OK', id: nil }
              end
          end
      end
      render json: { status: 'ERROR', id: nil }, :status => 400
  end

end
