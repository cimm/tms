require "json"
require "open-uri"
require "raw_status"
require "status"

class PublicTimeline
  TIMELINE_BASE_URL = "https://api.twitter.com/1/statuses/user_timeline.json?include_rts=true&trim_user=true"

  def initialize(user, since_id)
    @user     = user
    @since_id = since_id
  end

  def raw_timeline
    open(timeline_url).read
  end

  def timeline
    JSON.parse(raw_timeline)
  end

  def statuses
    statuses = []
    timeline.each do |json_status|
      raw_status = RawStatus.new(json_status)
      statuses << Status.from_raw_status(raw_status)
    end
    $log.info("The public timeline has #{statuses.count} statuses")
    statuses
  end

  def timeline_url
    "#{TIMELINE_BASE_URL}&screen_name=#{@user}&since_id=#{@since_id}"
  end
end
