class Sitemap < ActiveRecord::Base
    require 'uri'

    def self.add url, controller, page_title
        self.where(url: URI::decode(url), controller: controller, page_title: page_title).first_or_create
    end
end
