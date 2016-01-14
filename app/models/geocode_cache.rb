class GeocodeCache < ActiveRecord::Base

    def self.load addr
        loc = GeocodeCache.where(addr: addr).where('updated_at >= ?', 1.month.ago).first
        unless loc == nil
            return  { 'lat' => loc.latitude, 'lng' => loc.longitude }
        else
            return nil
        end
    end

    def self.save addr, loc
        unless loc == nil
            lat = loc['lat']
            lng = loc['lng']
        else
            lat = lng = nil
        end
        old = self.find_by(addr: addr)
        if old == nil
            cache = self.create(
            addr: addr,
            latitude: lat,
            longitude: lng
            )
            cache.save
        else
            old.latitude = lat
            old.longitude = lng
            old.save
        end
    end

end
