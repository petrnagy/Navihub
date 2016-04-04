class ApiCache < ActiveRecord::Base

  require 'yaml'

  def self.get_from_cache key
    row = self.find_by(key: key)
    if row && row.updated_at > (Time.now - 86400)
      return YAML::load row.data
    end
    return nil
  end

  def self.save_to_cache key, data
    data = YAML::dump data
    cache = self.find_by(key: key)
    if cache
      cache.update(data: data)
    else
      cache = self.create(key: key, data: data)
    end
    cache.save
  end

end
