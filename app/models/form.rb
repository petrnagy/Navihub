class Form < ActiveRecord::Base

  #require 'json'
  require 'digest/md5'

  def self.save_contact_feedback_form data
    data['type'] = 'Contact form - /feedback'
    key = Digest::MD5.hexdigest([data['name'], data['email'], data['message']].to_json)
    form = Form.find_by(key: key)
    if nil == form
      Form.create(name: data['name'], email: data['email'], text: data['message'], data: nil, spam: false, key: key)
      true
    else
      false
    end
  end

  private

end
