class SharerMailer < ActionMailer::Base

  include SearchMixin

  add_template_helper(ApplicationHelper)

  default from: "Navihub <noreply@navihub.net>"

  def share_via_email recipient, data
    @page_name = Rails.configuration.page_name
    @page_title = Rails.configuration.page_title
    @host = Rails.configuration.action_mailer.default_url_options[:host]
    @recipient = recipient
    @subject = 'Place detail: ' + data[:name].to_s + ' | ' + @page_name
    @data = data
    @data[:has_geometry] = has_geometry @data
    #@data[:url] = @host + '/detail/'

    # TODO: nastavit spravne host
    # todo: nastavit spravne url detailu (nova metoda)
    mail(to: recipient, subject: @subject)
  end

end
