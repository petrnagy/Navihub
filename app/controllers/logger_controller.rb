class LoggerController < ApplicationController

    class JavascriptError < StandardError
    end

    def js
        logger = Logger.new(STDERR)
        logger.error( JavascriptError.new(js_params) )
        render :json => { :status => "ok", :message => "Logged." }
    end

    private

    def js_params
        %w{summary msg url line extra details}.each do |param|
            params[param] = nil unless params.has_key? param
        end

        ret = params.permit(:summary, :msg, :url, :line, :extra, :details)
        ret[:details] = params[:details] if params.has_key? 'details'
        ret
    end

end
