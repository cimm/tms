class Mood
  CLASSIFICATION_SECTION = "cls1"

  def initialize(mood_json)
    @mood_json = mood_json
  end

  def happy_score
    round_score(@mood_json[CLASSIFICATION_SECTION]["happy"])
  end

  def round_score(score)
    (score * 100).to_i
  end
end
