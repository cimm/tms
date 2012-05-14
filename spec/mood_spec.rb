require "spec_helper"
require "mood"

describe Mood do
  CLASSIFICATION_SECTION = "cls1"

  let(:mood_json) { mock("Raw mood JSON") }
  let(:mood)      { Mood.new(mood_json) }

  describe :happy_score do
    let(:happy_score)         { 0.6070 }
    let(:rounded_happy_score) { 60 }
    let(:mood_json)           { { CLASSIFICATION_SECTION => { "happy" => happy_score } } }

    it "rounds the happy score" do
      mood.should_receive(:round_score).with(happy_score)
      mood.happy_score
    end

    it "returns the happy score" do
      mood.happy_score.should eql rounded_happy_score
    end
  end

  describe :round_score do
    let(:score)         { 0.6070 }
    let(:rounded_score) { 60 }

    it "returns the rounded score" do
      mood.round_score(score).should eql rounded_score
    end
  end
end
