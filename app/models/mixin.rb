class Mixin
  
  def self.normalize_unicode str
    require 'iconv'
    str.force_encoding('UTF-8')
    Iconv.conv('ASCII//TRANSLIT//IGNORE', 'UTF-8', str).gsub(' ', '-').gsub(/[^\d\w\-]/, '').downcase
  end
  
  def self.normalize_tag tag
    tag.gsub('_', '-').gsub(' ', '-').downcase
  end
  
end
