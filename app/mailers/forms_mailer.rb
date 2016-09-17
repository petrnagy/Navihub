class FormsMailer < ActionMailer::Base

    default from: "Navihub <noreply@navihub.net>"

    def new_feedback data
        @page_name = Rails.configuration.page_name
        @page_title = Rails.configuration.page_title
        @host = Rails.configuration.action_mailer.default_url_options[:host]
        @recipient = Rails.configuration.action_mailer.default_url_options[:admin_email]
        @subject = 'New feedback from ' + data[:name]
        @data = data

        mail(to: @recipient, subject: @subject, reply_to: data[:email])
    end
end
