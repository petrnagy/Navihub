json.array!(@favorites) do |favorite|
  json.extract! favorite, :id, :venue_origin, :venue_id, :user_id, :yield
  json.url favorite_url(favorite, format: :json)
end
