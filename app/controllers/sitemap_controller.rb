class SitemapController < ApplicationController

    def main
        #fresh_when last_modified: Time.now
        return render 'sitemap/sitemap.xml.erb'
    end

    def app
        # routes = Rails.application.routes.routes.to_a
        # routes.each do |route|
        # end
        @routes = [
            { path: '',                          priority: 1.0,      changefreq: 'daily' },
            { path: '/account',                  priority: 0.5,      changefreq: 'daily' },
            { path: '/account/index',            priority: 0.1,      changefreq: 'daily' },
            { path: '/account/login',            priority: 0.1,      changefreq: 'daily' },
            { path: '/account/create',           priority: 0.5,      changefreq: 'daily' },
            { path: '/settings/location',        priority: 0.1,      changefreq: 'daily' },
            { path: '/search',                   priority: 0.9,      changefreq: 'daily' },
            { path: '/favorites',                priority: 0.1,      changefreq: 'daily' },
        ]
        return render 'sitemap/app-sitemap.xml.erb'
    end

    def robots
        return render 'sitemap/robots.txt.erb'
    end

    protected

    def init
        @root_url = request.protocol + request.host_with_port
        @lastmod = Time.now.strftime '%Y-%m-%d'
    end

end
