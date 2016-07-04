# Preview all emails at http://localhost:3000/rails/mailers/sharer_mailer
class SharerMailerPreview < ActionMailer::Preview
    def share_via_email
        user = User.first
        loc = Location.last
        detail = DetailController.new
        detail.instance_variable_set(:@user, user)
        detail.instance_variable_set(:@location, loc)

        data = detail.load_detail 'foursquare', '4f358579e4b0d605a5783660'
        ll = loc.latitude.to_s + ',' + loc.longitude.to_s

        SharerMailer.share_via_email 'foo@bar.com', data, ll
    end
end
