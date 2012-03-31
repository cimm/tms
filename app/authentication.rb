require "oauth"
require "settings"

class Authentication
  CONSUMER_KEY        = Settings.twitter.consumer_key
  CONSUMER_SECRET     = Settings.twitter.consumer_secret
  ACCESS_TOKEN        = Settings.twitter.access_token
  ACCESS_TOKEN_SECRET = Settings.twitter.access_token_secret
  OAUTH_OPTIONS       = { :site => "https://api.twitter.com" }

  def self.access_token
    consumer = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, OAUTH_OPTIONS)
    OAuth::AccessToken.new(consumer, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
  end
end
