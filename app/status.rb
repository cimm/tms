require "data_mapper"
require "settings"
require "classification"

class Status
  include DataMapper::Resource

  MAXIMUM_STATUS_LENGTH    = 144
  STATUS_LIFTIME_IN_MONTHS = Settings.archiving.lifetime_in_months
  TAKE_OFFLINE_BASE_URL    = "http://api.twitter.com/1/statuses/destroy/"
  TAKE_OFFLINE_URL_FORMAT  = "json"
  TAKE_OFFLINE_URL_OPTIONS = "include_entities=false&trim_user=true"
  HTTP_SUCCESS_CODE        = "200"

  property :id,                    String, :key => true
  property :created_at,            DateTime, :required => true
  property :removed_at,            DateTime
  property :favorited,             Boolean, :required => true, :default => false
  property :retweet_count,         Integer
  property :truncated,             Boolean, :required => true, :default => false
  property :latitude,              Decimal, :precision => 10, :scale => 2
  property :longitude,             Decimal, :precision => 10, :scale => 2
  property :in_reply_to_user_id,   String
  property :in_reply_to_status_id, String
  property :text,                  String, :required => true, :length => MAXIMUM_STATUS_LENGTH
  property :happy_score,           Integer

  validates_within :happy_score, :set => 0..100

  def self.old
    all(:created_at.lte => old_status_date)
  end

  def self.not_removed
    all(:removed_at => nil)
  end

  def self.old_status_date
    Date.today << STATUS_LIFTIME_IN_MONTHS
  end

  def self.last_id
    any? ? last.id : "1"
  end

  def self.old_and_not_removed
    old.not_removed
  end

  def self.from_raw_status(raw_status)
    status                       = new
    status.id                    = raw_status.id
    status.created_at            = raw_status.created_at
    status.favorited             = raw_status.favorited?
    status.retweet_count         = raw_status.retweet_count
    status.truncated             = raw_status.truncated?
    status.latitude              = raw_status.latitude
    status.longitude             = raw_status.longitude
    status.in_reply_to_user_id   = raw_status.in_reply_to_user_id
    status.in_reply_to_status_id = raw_status.in_reply_to_status_id
    status.text                  = raw_status.text
    status
  end

  def classify
    self.happy_score = Classification.happy_score_for_text(text)
  end

  def take_offline(access_token)
    response = access_token.post(take_offline_url)
    if response.code == HTTP_SUCCESS_CODE
      update(:removed_at => Time.now)
      $log.info("Status #{id} removed")
    else
      $log.warn("Failed to remove status #{id} (#{response.code})")
    end
  end

  def take_offline_url
    "#{TAKE_OFFLINE_BASE_URL}#{id}.#{TAKE_OFFLINE_URL_FORMAT}?#{TAKE_OFFLINE_URL_OPTIONS}"
  end
end
