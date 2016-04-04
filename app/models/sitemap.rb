class Sitemap < ActiveRecord::Base
    def self.add url, controller
        self.where(url: url, controller: controller).first_or_create
    end
end
