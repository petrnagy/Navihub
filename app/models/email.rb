class Email < ActiveRecord::Base

    require 'digest/md5'

    def self.push_venue_share recipient, sender, data

        hash = Digest::MD5.hexdigest( YAML::dump([recipient, sender, data]) )
        exists = Email.where(email_hash: hash).where('created_at >= ?', 5.minutes.ago).first

        unless exists
            self.create(
            recipient: recipient,
            sender: sender,
            subject: 'Info about ' + data[:name].to_str,
            content: nil,
            email_type: 'detail',
            tries: 0,
            sent: nil,
            email_hash: hash
            )
        end

    end

end
