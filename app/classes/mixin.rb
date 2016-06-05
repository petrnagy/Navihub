class Mixin

  require 'digest/md5'

  def self.normalize_unicode str
    require 'iconv'
    str.force_encoding('UTF-8')
    Iconv.conv('ASCII//TRANSLIT//IGNORE', 'UTF-8', str).gsub(' ', '-').gsub(/[^\d\w\-]/, '').downcase
  end

  def self.normalize_tag tag
    tag.gsub(/( |_)+/, '-').gsub(/-+/, '-').gsub('/', ',').downcase
  end

  def self.sanitize txt
    ActionController::Base.helpers.sanitize(txt)
  end

  def self.is_ascii txt
    txt =~ /^[\x00-\x7F]+$/
  end

  def self.generate_random_hash len
    (Digest::MD5.hexdigest(Random.new_seed.to_s))[0..len]
  end

  def self.round5 num
      (num * 2).round.to_f / 2
  end

end
