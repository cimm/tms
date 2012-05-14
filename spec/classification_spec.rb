require "spec_helper"
require "classification"

describe Classification do
  MOOD_CLASSIFICATION_BASE_URL    = "http://uclassify.com/browse/prfekt/Mood/ClassifyText?text="
  MOOD_CLASSIFICATION_URL_OPTIONS = "readkey=#{Settings.uclassify.read_key}&output=json"

  let(:text)           { "Text to classify" }
  let(:classification) { Classification.new(text) }

  describe "self.happy_score_for_text" do
    let(:text)               { mock("Text") }
    let(:new_classification) { mock("Classification") }
    let(:happy_score)        { mock("Happy score") }

    before :each do
      Classification.stub(:new => new_classification)
      new_classification.stub(:happy_score => happy_score)
    end

    it "builds a new classification" do
      Classification.should_receive(:new).with(text)
      Classification.happy_score_for_text(text)
    end

    it "gets the happy score from the new classification" do
      new_classification.should_receive(:happy_score)
      Classification.happy_score_for_text(text)
    end

    it "returns the happy score" do
      Classification.happy_score_for_text(text).should eql happy_score
    end
  end

  describe :happy_score do
    let(:json_mood)   { mock("JSON mood") }
    let(:mood)        { mock("Mood") }
    let(:happy_score) { mock("Happy score") }

    before :each do
      classification.stub(:json_mood => json_mood)
      Mood.stub(:new => mood)
      mood.stub(:happy_score => happy_score)
    end

    it "gets the JSON mood" do
      classification.should_receive(:json_mood)
      classification.happy_score
    end

    it "builds a mood from the JSON mood" do
      Mood.should_receive(:new).with(json_mood)
      classification.happy_score
    end

    it "gets the happy score from the mood" do
      mood.should_receive(:happy_score)
      classification.happy_score
    end

    it "returns the happy mood" do
      classification.happy_score.should eql happy_score
    end
  end

  describe :raw_json_mood do
    let(:mood_classification_url) { "Mood classification URL" }
    let(:url_handle)              { mock("URL handle") }
    let(:raw_json_mood)           { mock("Raw JSON mood") }

    before :each do
      classification.stub(:mood_classification_url => mood_classification_url, :open => url_handle)
      url_handle.stub(:read => raw_json_mood)
    end

    it "gets the mood classification URL" do
      classification.should_receive(:mood_classification_url)
      classification.raw_json_mood
    end

    it "opens the mood classification URL" do
      classification.should_receive(:open).with(mood_classification_url)
      classification.raw_json_mood
    end

    it "reads the mood" do
      url_handle.should_receive(:read)
      classification.raw_json_mood
    end

    it "returns the raw mood" do
      classification.raw_json_mood.should eql raw_json_mood
    end
  end

  describe :json_mood do
    let(:raw_json_mood) { mock("Raw JSON mood") }
    let(:json_mood)     { mock("JSON mood") }

    before :each do
      classification.stub(:raw_json_mood => raw_json_mood)
      JSON.stub(:parse => json_mood)
    end

    it "gets the raw JSON mood" do
      classification.should_receive(:raw_json_mood)
      classification.json_mood
    end

    it "parses the raw JSON mood" do
      JSON.should_receive(:parse).with(raw_json_mood)
      classification.json_mood
    end

    it "returns the JSON mood" do
      classification.json_mood.should eql json_mood
    end
  end
  
  describe :mood_classification_url do
    let(:uri_encoded_text)        { URI.encode(text) }
    let(:mood_classification_url) { "#{MOOD_CLASSIFICATION_BASE_URL}#{uri_encoded_text}&#{MOOD_CLASSIFICATION_URL_OPTIONS}" }

    before :each do
      URI.stub(:encode => uri_encoded_text)
    end

    it "URI encodes the text" do
      URI.should_receive(:encode)
      classification.mood_classification_url
    end

    it "returns the URL needed to classify the mood of the text" do
      classification.mood_classification_url.should eql mood_classification_url
    end
  end
end
