class PagesController < ApplicationController

    # TODO: title, desc, kw, ...

    def privacy_policy
        @page_title = 'Privacy Policy'
    end

    def cookie_policy
        @page_title = 'Cookie Policy'
    end

    def terms_of_use
        @page_title = 'Terms of Use'
    end

    def data_sources
        @page_title = 'Data Sources'
    end

    def about
        @page_title = 'About'
    end

    def share
        @page_title = 'Share this cool page !'
    end

end
