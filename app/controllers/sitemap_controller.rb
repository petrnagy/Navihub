class SitemapController < ApplicationController

    require 'uri'

    FORMAT = '%Y-%m-%dT%H:%M:%S%:z'

    def main
        #fresh_when last_modified: Time.now
        return render 'sitemap/sitemap.xml.erb'
    end

    def app
        # routes = Rails.application.routes.routes.to_a
        # routes.each do |route|
        # end
        @routes = [
            { path: '',                          priority: 1.0, changefreq: 'daily', lastmod: @lastmod },
            { path: '/account',                  priority: 0.5, changefreq: 'daily', lastmod: @lastmod },
            { path: '/account/index',            priority: 0.1, changefreq: 'daily', lastmod: @lastmod },
            { path: '/account/login',            priority: 0.1, changefreq: 'daily', lastmod: @lastmod },
            { path: '/account/create',           priority: 0.5, changefreq: 'daily', lastmod: @lastmod },
            { path: '/settings/location',        priority: 0.1, changefreq: 'daily', lastmod: @lastmod },
            { path: '/search',                   priority: 0.9, changefreq: 'daily', lastmod: @lastmod },
            { path: '/favorites',                priority: 0.1, changefreq: 'daily', lastmod: @lastmod },
        ]
        return render 'sitemap/app-sitemap.xml.erb'
    end

    def search
        @routes = []
        Sitemap.where(controller: 'search').each do |row|
            @routes << { path: URI::encode(row.url), priority: 0.5, changefreq: 'daily', lastmod: row.updated_at.strftime(FORMAT) }
        end
        return render 'sitemap/app-sitemap.xml.erb'
    end

    def detail
        @routes = []
        Sitemap.where(controller: 'detail').each do |row|
            @routes << { path: URI::encode(row.url), priority: 0.5, changefreq: 'weekly', lastmod: row.updated_at.strftime(FORMAT) }
        end
        return render 'sitemap/detail-sitemap.xml.erb'
    end

    def permalink
        @routes = []
        Sitemap.where(controller: 'permalinks').each do |row|
            @routes << { path: URI::encode(row.url), priority: 0.5, changefreq: 'monthly', lastmod: row.updated_at.strftime(FORMAT) }
        end
        return render 'sitemap/permalink-sitemap.xml.erb'
    end

    def robots
        return render 'sitemap/robots.txt.erb'
    end

    protected

    def init
        @root_url = request.protocol + request.host_with_port
        @lastmod = Time.now.strftime FORMAT
    end

end
