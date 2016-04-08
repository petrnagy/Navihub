class Sitemap < ActiveRecord::Base
    def self.add url, controller, page_title
        self.where(url: url, controller: controller, page_title: page_title).first_or_create
    end
end
