class Location < ActiveRecord::Base
    belongs_to :user

    def self.update_user_loc data, user_id
        old = self.get_user_loc user_id
        if old != nil
            old.update(
            latitude:       data['lat'],
            longitude:      data['lng'],
            lock:           data['lock'],
            country:        data['country'],
            country_short:  data['country_short'],
            city:           data['city'],
            city2:          data['city2'],
            street1:        data['street1'],
            street2:        data['street2']
            )
            old
        else
            loc = Location.create(
            user_id:        user_id,
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
            loc
        end
        # loc = Location.create(
        # user_id:        user_id,
        # latitude:       data['lat'],
        # longitude:      data['lng'],
        # lock:           data['lock'],
        # country:        data['country'],
        # country_short:  data['country_short'],
        # city:           data['city'],
        # city2:          data['city2'],
        # street1:        data['street1'],
        # street2:        data['street2'],
        # active:         true
        # )
        # loc.save
        # Location.where(user_id: user_id).where.not(id: loc.id).update_all(active: false)
        # loc
    end

    def self.get_user_loc user_id
        return Location.where(user_id: user_id, active: true).order('id DESC').first
    end

    def self.possible lat, lng
        (lat.to_f <= 90 && lat.to_f >= -90 && lng.to_f <= 180 && lng.to_f >= -180)
    end

    def self.pretty_loc lat, lng
        lat_dms = deg_to_dms lat
        lng_dms = deg_to_dms lng
        lat_dms[3] = (lat > 0 ? 'N' : 'S')
        lng_dms[3] = (lng > 0 ? 'E' : 'W')
        { :lat => lat_dms, :lng => lng_dms }
    end

    def self.deg_to_dms deg
        d = deg.to_i
        md = (deg - d).abs * 60
        m = (md).to_i
        sd = ((md - m) * 60).to_i
        return [d, m, sd]
    end

    def self.calculate_distance lat1, lng1, lat2, lng2
        if self.possible(lat1, lng1) && self.possible(lat2, lng2)
            radius = 6371.00
            rads_per_degree = Math::PI / 180
            delta_lat = (lat2 - lat1) * rads_per_degree
            delta_lng = (lng2 - lng1) * rads_per_degree
            lat1 = lat1 * rads_per_degree
            lat2 = lat2 * rads_per_degree

            a = (Math.sin(delta_lat / 2)**2) + (Math.sin(delta_lng / 2)**2 * Math.cos(lat1) * Math.cos(lat2))
            c = (2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)))
            d = (radius * c).abs * 1000 # meters
        end
    end

end
