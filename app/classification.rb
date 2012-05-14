require "data_mapper"
require "open-uri"
require "json"
require "settings"
require "mood"

class Classification

  MOOD_CLASSIFICATION_BASE_URL    = "http://uclassify.com/browse/prfekt/Mood/ClassifyText?text="
  MOOD_CLASSIFICATION_URL_OPTIONS = "readkey=#{Settings.uclassify.read_key}&output=json"

  def self.happy_score_for_text(text)
    classification = new(text)
    classification.happy_score
  end

  def initialize(text)
    @text = text
  end

  def happy_score
    mood = Mood.new(json_mood)
    mood.happy_score
  end

  def raw_json_mood
    open(mood_classification_url).read
  end

  def json_mood
    JSON.parse(raw_json_mood)
  end

  def mood_classification_url
    uri_encoded_text = URI.encode(@text)
    "#{MOOD_CLASSIFICATION_BASE_URL}#{uri_encoded_text}&#{MOOD_CLASSIFICATION_URL_OPTIONS}"
  end
end
