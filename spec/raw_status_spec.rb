require "spec_helper"
require "date"
require "raw_status"

describe RawStatus do
  XML_SCHEMA_DATE_FORMAT = "%a %b %d %H:%M:%S %z %Y"

  let(:raw_status_json) { mock("Raw status JSON") }
  let(:raw_status)      { RawStatus.new(raw_status_json) }

  describe :id do
    let(:id)              { rand(1000).to_s }
    let(:raw_status_json) { { "id_str" => id } }

    it "returns the raw status id" do
      raw_status.id.should eql id
    end
  end

  describe :created_at do
    let(:raw_status_json) { { "created_at" => "Thu Mar 22 18:22:20 +0000 2012" } }

    it "converts the raw created date to and ISO" do
      DateTime.should_receive(:strptime).with(raw_status_json["created_at"], XML_SCHEMA_DATE_FORMAT)
      raw_status.created_at
    end
  end

  describe :favorited? do
    context "has been favorited" do
      let(:raw_status_json) { { "favorited" => true } }

      it "returns true" do
        raw_status.should be_favorited
      end
    end

    context "has not been favorited" do
      let(:raw_status_json) { { "favorited" => false } }

      it "returns false" do
        raw_status.should_not be_favorited
      end
    end
  end

  describe :retweeted? do
    context "has been retweeted" do
      let(:raw_status_json) { { "retweeted" => true } }

      it "returns true" do
        raw_status.should be_retweeted
      end
    end

    context "has not been retweeted" do
      let(:raw_status_json) { { "retweeted" => false } }

      it "returns false" do
        raw_status.should_not be_retweeted
      end
    end
  end

  describe :retweet_count do
    let(:retweet_count)   { rand(10) }
    let(:raw_status_json) { { "retweet_count" => retweet_count } }

    it "returns the retweet count" do
      raw_status.retweet_count.should eql retweet_count
    end
  end

  describe :truncated? do
    context "has been truncated" do
      let(:raw_status_json) { { "truncated" => true } }

      it "returns true" do
        raw_status.should be_truncated
      end
    end

    context "has not been truncated" do
      let(:raw_status_json) { { "truncated" => false } }

      it "returns false" do
        raw_status.should_not be_truncated
      end
    end
  end

  describe :coordinates do
    context "when the status has coordinates" do
      let(:coordinates)     { [mock("Latitude"), mock("Longitude")] }
      let(:raw_status_json) { { "coordinates" => coordinates } }

      it "returns the coordinates" do
        raw_status.coordinates.should eql coordinates
      end
    end


    context "when the status has no coordinates" do
      let(:raw_status_json) { { "coordinates" => nil } }

      it "returns an empty array" do
        raw_status.coordinates.should eql []
      end
    end
  end

  describe :latitude do
    let(:latitude)    { mock("Latitude") }
    let(:coordinates) { [latitude, mock("Longitude")] }

    before :each do
      raw_status.stub(:coordinates => coordinates)
    end

    it "gets the coordinates" do
      raw_status.should_receive(:coordinates)
      raw_status.latitude
    end

    it "returns the latitude" do
      raw_status.latitude.should eql latitude
    end
  end

  describe :longitude do
    let(:longitude)   { mock("Longitude") }
    let(:coordinates) { [mock("Latitude"), longitude] }

    before :each do
      raw_status.stub(:coordinates => coordinates)
    end

    it "gets the coordinates" do
      raw_status.should_receive(:coordinates)
      raw_status.longitude
    end

    it "returns the longitude" do
      raw_status.longitude.should eql longitude
    end
  end

  describe :in_reply_to_user_id do
    let(:in_reply_to_user_id) { rand(1000).to_s }
    let(:raw_status_json)     { { "in_reply_to_user_id_str" => in_reply_to_user_id } }

    it "returns the in reply to user id" do
      raw_status.in_reply_to_user_id.should eql in_reply_to_user_id
    end
  end

  describe :in_reply_to_status_id do
    let(:in_reply_to_status_id) { rand(1000).to_s }
    let(:raw_status_json)       { { "in_reply_to_status_id_str" => in_reply_to_status_id } }

    it "returns the in reply to raw status id" do
      raw_status.in_reply_to_status_id.should eql in_reply_to_status_id
    end
  end

  describe :text do
    let(:text)            { "Hello bird, this is a tweet." }
    let(:raw_status_json) { { "text" => text } }

    it "returns the raw status text" do
      raw_status.text.should eql text
    end
  end
end
