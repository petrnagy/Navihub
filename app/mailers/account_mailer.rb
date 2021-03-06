class AccountMailer < ActionMailer::Base

  default from: "Navihub <noreply@navihub.net>"

  def send_new_acc_email recipient, username, user_id
    @page_name = Rails.configuration.page_name
    @page_title = Rails.configuration.page_title
    @host = Rails.configuration.action_mailer.default_url_options[:host]
    @recipient = recipient
    @username = username
    @subject = 'New account created: ' + username + ' | ' + @page_name
    @hash = AccountHelper::generate_verify_hash recipient
    @link = url_for host: @host, controller: 'account', action: 'verify', username: username, hash: @hash

    mail(to: recipient, subject: @subject).deliver()
  end

end
