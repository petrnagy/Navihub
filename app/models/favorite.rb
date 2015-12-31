class Favorite < ActiveRecord::Base
    belongs_to :user

    def self.find_by_user_id user_id
        return Favorite.select('venue_id, venue_origin', conditions: { user_id: user_id } )
    end

    def self.load_by_user_id user_id
        return Favorite.where(user_id: user_id).order(created_at: :desc)
    end

    def self.find_by_params user_id, venue_origin, venue_id
        # TODO: COUNT(*)
        return Favorite.find_by(user_id: user_id, venue_origin: venue_origin, venue_id: venue_id)
    end

    def self.create_with_yield user_id, venue_origin, venue_id, yield_
        favorite = Favorite.new
        favorite.user_id = user_id
        favorite.venue_origin = venue_origin
        favorite.venue_id = venue_id
        favorite.yield = yield_
        favorite.save
    end

end
