module RecentMixin

    def recent
        controller = params[:controller]
        @controller = controller
        @step = 20
        @page = recent_params[:page]
        offset = (@page - 1) * @step
        @cnt = Sitemap.where(controller: controller).count
        @links = []
        Sitemap.where(controller: controller).offset(offset).limit(@step).order('id DESC').each do |row|
            @links << { path: URI::encode(row.url), title: unless row.page_title == nil then row.page_title else row.url end }
        end unless @cnt == 0
        if @page != 1 and @links.count == 0
            return redirect_to controller: controller, action: 'recent', page: 1
        end
        render controller + '/recent'
    end

    def recent_params
        if nil == params[:page] || params[:page].to_i <= 0
            params[:page] = 1
        end
        params[:page] = params[:page].to_i
        params.permit :page
    end

end
