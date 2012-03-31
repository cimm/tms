require "spec_helper"
require "public_timeline"

describe PublicTimeline do
  TIMELINE_BASE_URL = "https://api.twitter.com/1/statuses/user_timeline.json?include_rts=true&trim_user=true"

  let(:user)            { mock("Twitter user") }
  let(:since_id)        { mock("Since id") }
  let(:public_timeline) { PublicTimeline.new(user, since_id) }

  before :each do
    $log = mock("Logger", :info => nil)
  end

  describe :raw_timeline do
    let(:timeline_url) { "Timeline URL" }
    let(:url_handle)   { mock("URL handle") }
    let(:raw_timeline) { mock("URL handle") }

    before :each do
      public_timeline.stub(:timeline_url => timeline_url, :open => url_handle)
      url_handle.stub(:read => raw_timeline)
    end

    it "gets the timeline URL for the user" do
      public_timeline.should_receive(:timeline_url)
      public_timeline.raw_timeline
    end

    it "opens the timeline URL" do
      public_timeline.should_receive(:open).with(timeline_url)
      public_timeline.raw_timeline
    end

    it "reads the timeline" do
      url_handle.should_receive(:read)
      public_timeline.raw_timeline
    end

    it "returns the raw timeline" do
      public_timeline.raw_timeline.should eql raw_timeline
    end
  end

  describe :timeline do
    let(:raw_timeline) { mock("Raw timeline") }
    let(:timeline)     { mock("Timeline") }

    before :each do
      public_timeline.stub(:raw_timeline => raw_timeline)
      JSON.stub(:parse => timeline)
    end

    it "gets the raw timeline" do
      public_timeline.should_receive(:raw_timeline)
      public_timeline.timeline
    end

    it "parses the raw timeline" do
      JSON.should_receive(:parse).with(raw_timeline)
      public_timeline.timeline
    end

    it "returns the timeline" do
      public_timeline.timeline.should eql timeline
    end
  end

  describe :statuses do
    let(:json_status) { mock("JSON status") }
    let(:timeline)    { [json_status] }
    let(:raw_status)  { mock("Raw status") }
    let(:status)      { mock("Status") }
    let(:statuses)    { [status] }

    before :each do
      public_timeline.stub(:timeline => timeline)
      RawStatus.stub(:new => raw_status)
      Status.stub(:from_raw_status => status)
    end

    it "builds raw statuses from the JSON statuses" do
      timeline.each do |js|
        RawStatus.should_receive(:new).with(js)
      end
      public_timeline.statuses
    end

    it "builds statuses from the raw statuses" do
      timeline.each do |js|
        Status.should_receive(:from_raw_status).with(raw_status)
      end
      public_timeline.statuses
    end

    it "returns the list of statuses" do
      public_timeline.statuses.should eql statuses
    end
  end

  describe :public_timeline_url do
    let(:timeline_url) { "#{TIMELINE_BASE_URL}&screen_name=#{user}&since_id=#{since_id}" }

    it "returns the URL for the user's timeline" do
      public_timeline.timeline_url.should eql timeline_url
    end
  end
end
