# Preview all emails at http://localhost:3000/rails/mailers/sharer_mailer
class SharerMailerPreview < ActionMailer::Preview
    def share_via_email

        detail = DetailController.new
        detail.instance_variable_set(:@user, User.first)
        detail.instance_variable_set(:@location, Location.last)

        data = detail.load_detail 'foursquare', '4f358579e4b0d605a5783660'
        
        SharerMailer.share_via_email 'foo@bar.com', data
    end
end
