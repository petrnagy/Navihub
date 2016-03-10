# Preview all emails at http://localhost:3000/rails/mailers/account_mailer
class AccountMailerPreview < ActionMailer::Preview
    def send_new_acc_email
        AccountMailer.send_new_acc_email 'foo@bar.com', 'petr-nagy', 1
    end
end
