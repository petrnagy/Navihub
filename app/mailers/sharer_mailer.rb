class SharerMailer < ActionMailer::Base

    default from: "sharer@navihub.net"

    def share_via_email recipient, data
        @recipient = recipient
        @data = data
        mail(to: recipient, subject: 'Place detail: ' + data['name'].to_s + ' | navihub.net')
    end

end
