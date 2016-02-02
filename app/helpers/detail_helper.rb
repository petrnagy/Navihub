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
end
