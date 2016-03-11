Rails.application.config.middleware.use OmniAuth::Builder do
    provider :twitter, Rails.application.secrets.twitter_api_key, Rails.application.secrets.twitter_api_secret, {:image_size => 'bigger'}
    provider :facebook, Rails.application.secrets.facebook_app_id, Rails.application.secrets.facebook_app_secret
    provider :google_oauth2, Rails.application.secrets.google_client_id, Rails.application.secrets.google_client_secret
end
