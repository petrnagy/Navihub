class FeedbackController < ApplicationController

    class ParamWasNotString < StandardError
    end

    @errors = nil, @data = nil

    def index
        @form = Form.new
        @page_title = 'User feedback'
    end

    def process_contact_form
        @page_title = 'User feedback'
        parameters = process_contact_form_params
        @form = Form.new(parameters)

        if @form.valid?
            Form.save_contact_feedback_form(parameters)
            @page_title += ' - Success'
            render 'form_success'
        else
            @page_title += ' - Errors found'
            render 'index'
        end

    end

    private

    def process_contact_form_params
        params.require(:form).permit(:name, :email, :text)
    end

end
