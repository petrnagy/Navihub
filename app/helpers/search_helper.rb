module SearchHelper

    def url_for_search_without_distance p, ll # p = parameters
        if Mixin.is_ascii p['term']
            return '/search/' + p['term'] + '/' + p['order'] + '/0/' + p['offset'].to_s + '/@/' + ll
        else
            return '/search/' + p['order'] + '/0/' + p['offset'] + '/@/' + ll + '?term=' + p['term']
        end
    end

end
