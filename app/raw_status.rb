class RawStatus
  XML_SCHEMA_DATE_FORMAT = "%a %b %d %H:%M:%S %z %Y"

  def initialize(json_status_json)
    @json_status_json = json_status_json
  end

  def id
    @json_status_json["id_str"]
  end

  def from_user_id
    @json_status_json["user"]["id_str"]
  end

  def created_at
    DateTime.strptime(@json_status_json["created_at"], XML_SCHEMA_DATE_FORMAT)
  end

  def favorited?
    @json_status_json["favorited"]
  end

  def retweeted?
    @json_status_json["retweeted"]
  end

  def retweet_count
    @json_status_json["retweet_count"]
  end

  def truncated?
    @json_status_json["truncated"]
  end

  def coordinates
    @json_status_json["coordinates"] || []
  end

  def latitude
    coordinates.first
  end

  def longitude
    coordinates.last
  end

  def in_reply_to_user_id
    @json_status_json["in_reply_to_user_id_str"]
  end

  def in_reply_to_status_id
    @json_status_json["in_reply_to_status_id_str"]
  end

  def text
    @json_status_json["text"]
  end
end
