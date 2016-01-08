class Email < ActiveRecord::Base

    require 'digest/md5'

    def push_venue_share recipient, sender, data

        hash = Digest::MD5.hexdigest( YAML::dump([recipient, sender, data]) )
        exists = Email.where(hash: hash).where('created_at >= ?', 5.minutes.ago).first

        unless exists
            Email.create(
            recipient: recipient,
            sender: sender,
            subject: 'Info about ' + data['name'],
            content: nil,
            type: 'detail',
            tries: 0,
            sent: nil,
            hash: hash
            )
        end

    end

end
