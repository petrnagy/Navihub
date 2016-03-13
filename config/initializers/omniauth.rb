Rails.application.config.middleware.use OmniAuth::Builder do
    # https://github.com/arunagw/omniauth-twitter
    provider :twitter, Rails.application.secrets.twitter_api_key, Rails.application.secrets.twitter_api_secret, {:image_size => 'bigger'}
    # https://github.com/mkdynamic/omniauth-facebook
    provider :facebook, Rails.application.secrets.facebook_app_id, Rails.application.secrets.facebook_app_secret
    # https://github.com/zquestz/omniauth-google-oauth2
    provider :google_oauth2, Rails.application.secrets.google_client_id, Rails.application.secrets.google_client_secret, { skip_jwt: true }
end
