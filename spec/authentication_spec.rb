require "spec_helper"
require "authentication"

describe Authentication do
  CONSUMER_KEY        = Settings.twitter.consumer_key
  CONSUMER_SECRET     = Settings.twitter.consumer_secret
  ACCESS_TOKEN        = Settings.twitter.access_token
  ACCESS_TOKEN_SECRET = Settings.twitter.access_token_secret
  OAUTH_OPTIONS       = { :site => "https://api.twitter.com" }

  describe "self.access_token" do
    let(:consumer)     { mock("Consumer") }
    let(:access_token) { mock("Access token") }

    before :each do
      OAuth::Consumer.stub(:new => consumer)
      OAuth::AccessToken.stub(:new => access_token)
    end

    it "builds a new OAuth consumer" do
      OAuth::Consumer.should_receive(:new).with(CONSUMER_KEY, CONSUMER_SECRET, OAUTH_OPTIONS)
      Authentication.access_token
    end

    it "builds a new OAuth access token" do
      OAuth::AccessToken.should_receive(:new).with(consumer, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
      Authentication.access_token
    end
  end
end
