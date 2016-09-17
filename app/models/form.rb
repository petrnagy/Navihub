class Form < ActiveRecord::Base

    validates :name, presence: true
    validates :email, presence: true
    validates :text, presence: true

    #require 'json'
    require 'digest/md5'

    def self.save_contact_feedback_form data
        data[:type] = 'Contact form - /feedback'
        key = Digest::MD5.hexdigest([data[:name], data[:email], data[:text]].to_json)
        form = Form.find_by(key: key)
        if nil == form
            Form.create(name: data[:name], email: data[:email], text: data[:text], data: nil, spam: false, key: key)
            FormsMailer.new_feedback(data)
            true
        else
            false
        end
    end

    private

end
