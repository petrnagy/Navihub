# encoding: UTF-8

module DetailHelper

    def self.detail_pretty_loc pretty_loc, geometry
        o = ''
        o += '<p class="detail-window-p">'
        o += 'The GPS coordinates are <b>'
        if pretty_loc.is_a? String
            o += pretty_loc
        else
            o += pretty_loc[:lat][0].to_s + '°' + "<span class='geospace'>&nbsp;</span>" + pretty_loc[:lat][1].to_s + "'" + "<span class='geospace'>&nbsp;</span>" + pretty_loc[:lat][2].to_s + '"' + "<span class='geospace'>&nbsp;</span>" + pretty_loc[:lat][3].to_s + ', '
            o += pretty_loc[:lng][0].to_s + '°' + "<span class='geospace'>&nbsp;</span>" + pretty_loc[:lng][1].to_s + "'" + "<span class='geospace'>&nbsp;</span>" + pretty_loc[:lng][2].to_s + '"' + "<span class='geospace'>&nbsp;</span>" + pretty_loc[:lng][3].to_s
            o += '</b>, alternatively <i>lat ' + geometry[:lat].round(6).to_s + ' lng ' + geometry[:lng].round(6).to_s + '</i>.'
        end
        o += '</p>'
        o.html_safe
    end

    def self.detail_pretty_address name, address
        o = ''
        o += '<p class="detail-window-p">'
        o += 'The place ' + name + ' is located at <b>' + address + '</b>.'
        o += '</p>'
        o.html_safe
    end

    def self.detail_pretty_distance distance, distance_unit
        o = ''
        o += '<p class="detail-window-p">'
        o += '  This place is approximately <b>' + DistanceHelper.pretty_distance(distance, distance_unit, 'km', true) + '</b> away from your current location.'
        o += '</p>'
        o.html_safe
    end

    def self.detail_pretty_distance_foot distance
        o = ''
        o += '<p class="detail-window-p">'
        o += '  If you are going by foot, you will be there approximately in <b>' + DistanceHelper.pretty_minutes(DistanceHelper.m_to_min(distance), true) + '</b>.'
        o += '</p>'
        o.html_safe
    end

    def self.detail_pretty_distance_car distance
        o = ''
        o += '<p class="detail-window-p">'
        o += '  If you take the car, you will arrive in <b>' + DistanceHelper.pretty_minutes(DistanceHelper.car_m_to_min(distance), true) + '</b>.'
        o += '</p>'
        o.html_safe
    end

    def self.detail_pretty_distance_car_precomputed minutes
        o = ''
        o += '<p class="detail-window-p">'
        o += '  If you take the car, you will arrive in <b>' + DistanceHelper.pretty_minutes(minutes, true) + '</b>.'
        o += '</p>'
        o.html_safe
    end

end
