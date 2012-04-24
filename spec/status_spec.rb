require "spec_helper"
require "status"

describe Status do
  HTTP_SUCCESS_CODE        = "200"
  TAKE_OFFLINE_BASE_URL    = "http://api.twitter.com/1/statuses/destroy/"
  TAKE_OFFLINE_URL_FORMAT  = "json"
  TAKE_OFFLINE_URL_OPTIONS = "include_entities=false&trim_user=true"
  HTTP_ERROR_CODE          = "500"

  let(:status) { Status.new }

  before :each do
    $log = mock("Logger", :warn => nil, :info => nil)
  end

  it "has an id" do
    status.should respond_to(:id)
    status.should respond_to(:id=)
  end

  it "is not valid without an id" do
    status.should_not be_valid
    status.errors.should have_key(:id)
  end

  it "has the date it was created" do
    status.should respond_to(:created_at)
    status.should respond_to(:created_at=)
  end

  it "is not valid without a creation date" do
    status.should_not be_valid
    status.errors.should have_key(:created_at)
  end

  it "has the date it was removed" do
    status.should respond_to(:removed_at)
    status.should respond_to(:removed_at=)
  end

  it "knows if it was favorited" do
    status.should respond_to(:favorited?)
    status.should respond_to(:favorited=)
  end

  it "is not valid without knowing if it was favorited" do
    status.favorited = nil
    status.should_not be_valid
    status.errors.should have_key(:favorited)
  end

  it "is not favorited by default" do
    status.should_not be_favorited
  end

  it "has a retweet count" do
    status.should respond_to(:retweet_count)
    status.should respond_to(:retweet_count=)
  end

  it "knows if it was truncated" do
    status.should respond_to(:truncated?)
    status.should respond_to(:truncated=)
  end

  it "is not valid without knowing if it was truncated" do
    status.truncated = nil
    status.should_not be_valid
    status.errors.should have_key(:truncated)
  end

  it "is not truncated by default" do
    status.should_not be_truncated
  end

  it "has a latitude" do
    status.should respond_to(:latitude)
    status.should respond_to(:latitude=)
  end

  it "has a longitude" do
    status.should respond_to(:longitude)
    status.should respond_to(:longitude=)
  end

  it "has the user id it replied to" do
    status.should respond_to(:in_reply_to_user_id)
    status.should respond_to(:in_reply_to_user_id=)
  end

  it "has the status id it replied to" do
    status.should respond_to(:in_reply_to_status_id)
    status.should respond_to(:in_reply_to_status_id=)
  end

  it "has a text" do
    status.should respond_to(:text)
    status.should respond_to(:text=)
  end

  it "is not valid without text" do
    status.should_not be_valid
    status.errors.should have_key(:text)
  end

  it "has a text of maximum 144 characters" do
    status.text = "x" * 145
    status.should_not be_valid
    status.errors[:text].should include("Text must be at most 144 characters long")
  end

  describe "self.old" do
    let(:old_status_date) { mock("Old status date") }
    let(:query)           { {:created_at.lte => old_status_date } }
    let(:old_statuses)    { [mock("Status")] }

    before :each do
      Status.stub(:old_status_date => old_status_date, :all => old_statuses)
    end

    it "gets the date statuses are considered as old" do
      Status.should_receive(:old_status_date)
      Status.old
    end

    it "gets all statuses created before that date" do
      Status.should_receive(:all).with(query)
      Status.old
    end

    it "returns the old statuses" do
      Status.old.should eql old_statuses
    end
  end

  describe "self.not_removed" do
    let(:available_statuses) { [mock("Status")] }
    let(:query)              { { :removed_at => nil } }

    before :each do
      Status.stub(:all => available_statuses)
    end

    it "gets all the statuses that are not yet removed" do
      Status.should_receive(:all).with(query)
      Status.not_removed
    end

    it "returns all the statuses that are not yet removed" do
      Status.not_removed.should eql available_statuses
    end
  end

  describe "self.old_status_date" do
    let(:today)            { Date.strptime("2012-01-01", "%Y-%m-%d") }
    let(:three_months_ago) { Date.strptime("2011-10-01", "%Y-%m-%d") }

    before :each do
      Date.stub(:today => today)
    end

    it "returns the date of 3 months ago" do
      Status.old_status_date.should eql three_months_ago
    end
  end

  describe "self.old_and_not_removed" do
    let(:old_status_not_removed)   { mock("Old status not removed") }
    let(:old_statuses)             { [mock("Old removed status"), old_status_not_removed] }
    let(:old_statuses_not_removed) { [old_status_not_removed] }

    before :each do
      Status.stub(:old => old_statuses)
      old_statuses.stub(:not_removed => old_statuses_not_removed)
    end

    it "gets all the old statuses" do
      Status.should_receive(:old)
      Status.old_and_not_removed
    end

    it "keeps only the statuses that are not yet removed from the old statuses" do
      old_statuses.should_receive(:not_removed)
      Status.old_and_not_removed
    end

    it "returns only the old statuses that are not yet removed" do
      Status.old_and_not_removed.should eql old_statuses_not_removed
    end
  end

  describe "self.last_id" do
    context "when there are archived statuses" do
      let(:last_status)    { mock("Last status") }
      let(:last_status_id) { mock("Last status id") }

      before :each do
        Status.stub(:last => last_status)
        last_status.stub(:id => last_status_id)
        Status.stub(:any? => true)
      end

      it "gets the last status" do
        Status.should_receive(:last)
        Status.last_id
      end

      it "gets the id from the last status" do
        last_status.should_receive(:id)
        Status.last_id
      end

      it "returns the id from the last status" do
        Status.last_id.should eql last_status_id
      end
    end

    context "when there are no archived statuses" do
      before :each do
        Status.stub(:any? => false)
      end

      it "returns 1" do
        Status.last_id.should eql "1"
      end
    end
  end

  describe :from_raw_status do
    let(:raw_status)                       { mock("Raw status") }
    let(:raw_status_id)                    { mock("Raw status id") }
    let(:raw_status_created_at)            { mock("Raw status create date") }
    let(:raw_status_favorited)             { mock("Raw status favorited state") }
    let(:raw_status_retweet_count)         { mock("Raw status retweet count") }
    let(:raw_status_truncated)             { mock("Raw status truncated state") }
    let(:raw_status_latitude)              { mock("Raw status latitude") }
    let(:raw_status_longitude)             { mock("Raw status longitude") }
    let(:raw_status_in_reply_to_user_id)   { mock("Raw status in reply to user id") }
    let(:raw_status_in_reply_to_status_id) { mock("Raw status in reply to status id") }
    let(:raw_status_text)                  { mock("Raw status text") }

    before :each do
      Status.stub(:new => status)
      raw_status.stub(:id                    => raw_status_id,
                      :created_at            => raw_status_created_at,
                      :favorited?            => raw_status_favorited,
                      :retweet_count         => raw_status_retweet_count,
                      :truncated?            => raw_status_truncated,
                      :latitude              => raw_status_latitude,
                      :longitude             => raw_status_longitude,
                      :in_reply_to_user_id   => raw_status_in_reply_to_user_id,
                      :in_reply_to_status_id => raw_status_in_reply_to_status_id,
                      :text                  => raw_status_text)
    end

    it "builds a new status" do
      Status.should_receive(:new)
      Status.from_raw_status(raw_status)
    end

    it "gets the raw status id" do
      raw_status.should_receive(:id)
      Status.from_raw_status(raw_status)
    end

    it "sets the status id from the raw status" do
      status.should_receive(:id=).with(raw_status_id)
      Status.from_raw_status(raw_status)
    end

    it "gets the date the raw status was created" do
      raw_status.should_receive(:created_at)
      Status.from_raw_status(raw_status)
    end

    it "sets the status created date from the raw status" do
      status.should_receive(:created_at=).with(raw_status_created_at)
      Status.from_raw_status(raw_status)
    end

    it "checks if the raw status was favorited" do
      raw_status.should_receive(:favorited?)
      Status.from_raw_status(raw_status)
    end

    it "sets the status favorited state from the raw status" do
      status.should_receive(:favorited=).with(raw_status_favorited)
      Status.from_raw_status(raw_status)
    end

    it "gets the retweet count form the raw status" do
      raw_status.should_receive(:retweet_count)
      Status.from_raw_status(raw_status)
    end

    it "sets the status retweet count from the raw status" do
      status.should_receive(:retweet_count=).with(raw_status_retweet_count)
      Status.from_raw_status(raw_status)
    end

    it "checks if the raw status was truncated" do
      raw_status.should_receive(:truncated?)
      Status.from_raw_status(raw_status)
    end

    it "sets the status truncated state from the raw status" do
      status.should_receive(:truncated=).with(raw_status_truncated)
      Status.from_raw_status(raw_status)
    end

    it "gets the latitude form the raw status" do
      raw_status.should_receive(:latitude)
      Status.from_raw_status(raw_status)
    end

    it "sets the latitude from the raw status" do
      status.should_receive(:latitude=).with(raw_status_latitude)
      Status.from_raw_status(raw_status)
    end

    it "gets the longitude form the raw status" do
      raw_status.should_receive(:longitude)
      Status.from_raw_status(raw_status)
    end

    it "sets the longitude from the raw status" do
      status.should_receive(:longitude=).with(raw_status_longitude)
      Status.from_raw_status(raw_status)
    end

    it "gets the in reply to user id form the raw status" do
      raw_status.should_receive(:in_reply_to_user_id)
      Status.from_raw_status(raw_status)
    end

    it "sets the status in reply to user id from the raw status" do
      status.should_receive(:in_reply_to_user_id=).with(raw_status_in_reply_to_user_id)
      Status.from_raw_status(raw_status)
    end

    it "gets the in reply to status id form the raw status" do
      raw_status.should_receive(:in_reply_to_status_id)
      Status.from_raw_status(raw_status)
    end

    it "sets the status in reply to status id from the raw status" do
      status.should_receive(:in_reply_to_status_id=).with(raw_status_in_reply_to_status_id)
      Status.from_raw_status(raw_status)
    end

    it "gets the text form the raw status" do
      raw_status.should_receive(:text)
      Status.from_raw_status(raw_status)
    end

    it "sets the status text from the raw status" do
      status.should_receive(:text=).with(raw_status_text)
      Status.from_raw_status(raw_status)
    end

    it "returns the new status" do
      Status.from_raw_status(raw_status).should eql status
    end
  end

  describe :take_offline do
    let(:access_token)     { mock("Access token") }
    let(:take_offline_url) { mock("Take offline URL") }
    let(:response)         { mock("Response") }

    before :each do
      status.stub(:take_offline_url => take_offline_url, :update => nil)
      access_token.stub(:post => response)
      response.stub(:code => HTTP_SUCCESS_CODE)
    end

    it "gets the endpoint needed to take a status offline" do
      status.should_receive(:take_offline_url)
      status.take_offline(access_token)
    end

    it "posts the requests to the access token" do
      access_token.should_receive(:post).with(take_offline_url)
      status.take_offline(access_token)
    end

    context "when the post was successful" do
      let(:now) { Time.now }

      before :each do
        Time.stub(:now => now)
      end

      it "update the date the status was removed" do
        status.should_receive(:update).with(:removed_at => now)
        status.take_offline(access_token)
      end
    end

    context "when the post failed" do
      before :each do
        response.stub(:code => HTTP_ERROR_CODE)
      end

      it "does not flag the status as offline" do
        status.should_not_receive(:update)
        status.take_offline(access_token)
      end
    end
  end

  describe :take_offline_url do
    let(:id)               { mock("Id") }
    let(:take_offline_url) { "#{TAKE_OFFLINE_BASE_URL}#{id}.#{TAKE_OFFLINE_URL_FORMAT}?#{TAKE_OFFLINE_URL_OPTIONS}" }

    before :each do
      status.stub(:id => id)
    end

    it "returns the endpoint needed to take the status offline" do
      status.take_offline_url.should eql take_offline_url
    end
  end
end
