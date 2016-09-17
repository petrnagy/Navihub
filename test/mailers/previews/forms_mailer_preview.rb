# Preview all emails at http://localhost:3000/rails/mailers/forms_mailer
class FormsMailerPreview < ActionMailer::Preview

    # Preview this email at http://localhost:3000/rails/mailers/forms_mailer/new_feedback
    def new_feedback
        data = {
            :name => "Petr Nagy",
            :email => "petr.nagy@outlook.com",
            :text => "Lorem ipsum dolor sit amet"
        }
        FormsMailer.new_feedback(data)
    end

end
