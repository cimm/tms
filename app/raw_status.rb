class RawStatus
  XML_SCHEMA_DATE_FORMAT = "%a %b %d %H:%M:%S %z %Y"

  def initialize(raw_status)
    @raw_status = raw_status
  end

  def id
    @raw_status["id_str"]
  end

  def from_user_id
    @raw_status["user"]["id_str"]
  end

  def created_at
    DateTime.strptime(@raw_status["created_at"], XML_SCHEMA_DATE_FORMAT)
  end

  def favorited?
    @raw_status["favorited"]
  end

  def retweeted?
    @raw_status["retweeted"]
  end

  def retweet_count
    @raw_status["retweet_count"]
  end

  def truncated?
    @raw_status["truncated"]
  end

  def coordinates
    @raw_status["coordinates"] || []
  end

  def latitude
    coordinates.first
  end

  def longitude
    coordinates.last
  end

  def in_reply_to_user_id
    @raw_status["in_reply_to_user_id_str"]
  end

  def in_reply_to_status_id
    @raw_status["in_reply_to_status_id_str"]
  end

  def text
    @raw_status["text"]
  end
end
