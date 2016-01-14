class FeedbackController < ApplicationController

  class ParamWasNotString < StandardError
  end

  @errors = nil, @data = nil

  def index
  end

  def process_contact_form
    parameters = process_contact_form_params
    @errors = {}
    @data = {}

    parameters.each do |field|
      @data[field] = ''

      if validate_contact_form_field(field, params[field])
        @data[field] = params[field]
      else
        @errors[field] = true
      end
    end

    unless @errors.length > 0
      saved = Form.save_contact_feedback_form(@data)
      render 'contact-form-success' if saved
      render 'contact-form-internal-error' if not saved
    else
      render 'contact-form-error'
    end

  end

  private

  def process_contact_form_params
    %w{name email message}.each do |required|
      params.require required
      raise ParamWasNotString unless params[required].is_a(String)
    end

  end

  def validate_contact_form_field field, value
    # TODO: validovat e-mail a délky (ne jen  > 0)
    value.length > 0
  end

end
