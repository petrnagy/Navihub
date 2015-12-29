class ReverseGeocodeCache < ActiveRecord::Base

    def self.load lat, lng
        loc = ReverseGeocodeCache.where(latitude: lat).where(longitude: lng).where('updated_at >= ?', 1.month.ago).first
        unless loc == nil
            return  loc.addr
        else
            return nil
        end
    end

    def self.save lat, lng, addr
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