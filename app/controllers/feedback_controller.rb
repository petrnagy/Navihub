class FeedbackController < ApplicationController

  require 'json'
  require 'digest/md5'

  @errors = nil, @data = nil

  def index
  end

  def process_contact_form
    required = ['name', 'email', 'message']
    @errors = {}
    @data = {}

    required.each do |field|
      field = field.to_s
      @data[field] = ''

      if params.has_key?(field) && params[field].length > 0 && validate_contact_form_field(field, params[field])
        @data[field] = params[field].to_s
      else
        @errors[field] = true
      end
    end

    unless @errors.length > 0
      saved = save_contact_form(@data)
      send_contact_form_infomail form, @data if saved
      render 'contact-form-success'
    else
      render 'contact-form-error'
    end

  end

  private

  def validate_contact_form_field field, value
    # TODO: validovat e-mail a délky
    true
  end

  def save_contact_form data
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

  def send_contact_form_infomail form, data
    # TODO: not implemented
  end

end
