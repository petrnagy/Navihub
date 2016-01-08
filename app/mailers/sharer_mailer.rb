class SharerMailer < ActionMailer::Base

    default from: "noreply@navihub.net"

    def share_via_email recipient, data
        @page_name = Rails.configuration.page_name
        @page_title = Rails.configuration.page_title
        @host = Rails.configuration.action_mailer.default_url_options[:host]
        @recipient = recipient
        @subject = 'Place detail: ' + data[:name].to_s + ' | ' + @page_name
        @data = data
        l = Logger.new(STDOUT)
        l.debug data
        @data['url'] = @host + '/detail/'

        mail(to: recipient, subject: @subject)
    end

end
