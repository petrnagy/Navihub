class GoogleStaticMapCache < ActiveRecord::Base

    def self.load url
        self.where(url: url).where('updated_at >= ?', 1.month.ago).first
    end

    def self.save url, found, warn
        old = self.find_by(url: url)
        if old == nil
            cache = self.create(
            url: url,
            found: found,
            x_staticmap_api_warning: warn
            )
            cache.save
        else
            old.url = url
            old.found = found
            old.x_staticmap_api_warning = warn
            old.save
        end
    end

end
