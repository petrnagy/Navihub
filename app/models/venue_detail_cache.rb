class VenueDetailCache < ActiveRecord::Base

    def self.load origin, id
        row = self.where(venue_origin: origin).where(venue_id: id).where('updated_at >= ?', 1.month.ago).first
        if row == nil
            return nil
        else
            return YAML.load(row.yield)
        end
    end

    def self.save origin, id, data
        old = self.where(venue_origin: origin).where(venue_id: id).first
        if old == nil
            cache = self.create(
            venue_origin: origin,
            venue_id: id,
            yield: YAML.dump(data)
            )
            cache.save
        else
            old.yield = YAML.dump(data)
            old.save
        end
    end

end
