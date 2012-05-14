require "date"
require "data_mapper"
require "public_timeline"
require "status"
require "authentication"
require "settings"

class Application
  DATABASE_CONNECTION = Settings.database.connection
  TWITTER_USER        = Settings.twitter.user

  def self.start
    DataMapper.setup(:default, DATABASE_CONNECTION)
    DataMapper.auto_upgrade!
  end

  def self.archive_statuses
    public_timeline = PublicTimeline.new(TWITTER_USER, Status.last_id)
    public_timeline.statuses.each do |status|
      status.classify
      status.save!
    end
  end

  def self.take_old_statuses_offline
    old_statuses_not_removed = Status.old_and_not_removed
    $log.info("Found #{old_statuses_not_removed.count} old statuses")
    if old_statuses_not_removed.any?
      access_token = Authentication.access_token
      old_statuses_not_removed.each do |status|
        status.take_offline(access_token)
      end
    end
  end
end
