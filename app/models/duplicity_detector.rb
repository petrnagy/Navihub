class DuplicityDetector
  
  require 'text' # http://rubygems.org/gems/text
  
  private
  
  @sentence1; @sentence2; @term; @raw1; @raw2;
  
  public
  
  def initialize term, sentence1, sentence2
    set term, sentence1, sentence2
  end
  
  # returns similiarity score from 0.00 for different sentences and 1.00 for the same ones
  def get_score
    process
  end
  
  private
  
  def set term, sentence1, sentence2
    @term = term.strip.downcase
    @raw1 = sentence1
    @raw2 = sentence2
    @sentence1 = prepare sentence1
    @sentence2 = prepare sentence2
  end
  
  def prepare sentence
    prepared = sentence.clone
    prepared.strip!
    prepared.downcase!
    prepared.gsub! @term, ''
    prepared.gsub! /\ +/, ' '
    prepared.gsub! /([^\d\w\ \-]|_)/u, ' '
    prepared.split ' '
  end
  
  def process
    return 1.00 if are_same
    return 1.00 if are_both_empty # both arrays are empty, thus the same
    return 0.00 if is_just_one_empty # one array is empty and the other one is not -> not similiar at all
    
    comparator = Text::WhiteSimilarity.new
    similarity_raw = comparator.similarity @raw1, @raw2
    similarity_prepared = comparator.similarity @sentence1.join(' '), @sentence2.join(' ')
    
    similarity = ( similarity_raw + similarity_prepared ) / 2
    score = similarity
    
    shorter = get_shorter_array
    longer = get_longer_array
      
    if is_subarray shorter, longer
      score += (0.25 * shorter.length) # longer array contains all the elements from the shorter array
    end
      
    score += get_contains_cnt(shorter, longer) * 0.25
    
    score
  end
  
  def are_same
    @sentence1.join(' ') == @sentence2.join(' ')
  end
  
  def are_both_empty
    ! @sentence1.length && ! @sentence2.length
  end
  
  def is_just_one_empty
    ( ! @sentence1.length && @sentence2.length ) || ( @sentence1.length && ! @sentence2.length )
  end
  
  def get_shorter_array
    @sentence1.length < @sentence2.length ? @sentence1 : @sentence2
  end
  
  def get_longer_array
    @sentence1.length > @sentence2.length ? @sentence1 : @sentence2
  end
  
  def is_subarray shorter, longer
    hits = 0
    shorter.each do |word|
      hits += 1 if longer.include? word
    end
    shorter.length == hits
  end
  
  def get_contains_cnt shorter, longer
    hits = 0
    shorter.each do |word|
      hits += 1 if longer.include? word
    end
    hits
  end
  
end