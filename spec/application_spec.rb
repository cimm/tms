require "spec_helper"
require "application"

describe Application do
  DATABASE_CONNECTION = Settings.database.connection
  TWITTER_USER        = Settings.twitter.user

  before :each do
    $log = mock("Logger", :info => nil)
  end

  describe "self.start" do
    before :each do
      DataMapper.stub(:setup => nil, :auto_upgrade! => nil)
    end

    it "sets the default database connection" do
      DataMapper.should_receive(:setup).with(:default, DATABASE_CONNECTION)
      Application.start
    end

    it "upgrades the database schema to the latest version" do
      DataMapper.should_receive(:auto_upgrade!)
      Application.start
    end
  end

  describe "self.archive_statuses" do
    let(:last_id)         { mock("last_id") }
    let(:public_timeline) { mock("Public timeline") }
    let(:status)          { mock("Status") }
    let(:statuses)        { [status] }

    before :each do
      Status.stub(:last_id => last_id)
      PublicTimeline.stub(:new => public_timeline)
      public_timeline.stub(:statuses => statuses)
      status.stub(:save!)
    end

    it "gets the id of the last archived status" do
      Status.should_receive(:last_id)
      Application.archive_statuses
    end

    it "gets the public timeline since the last archived status" do
      PublicTimeline.should_receive(:new).with(TWITTER_USER, last_id)
      Application.archive_statuses
    end

    it "gets the new statuses from the public timeline" do
      public_timeline.should_receive(:statuses)
      Application.archive_statuses
    end

    it "persists each of these statuses" do
      statuses.each do |s|
        s.should_receive(:save!)
      end
      Application.archive_statuses
    end
  end

  describe "self.take_old_statuses_offline" do
    let(:old_online_status)   { mock("Old online status") }
    let(:old_online_statuses) { [old_online_status] }
    let(:access_token)        { mock("Access token") }

    before :each do
      Status.stub(:old_and_online => old_online_statuses)
      Authentication.stub(:access_token => access_token)
      old_online_status.stub(:take_offline)
    end

    it "gets the old but still online statuses" do
      Status.should_receive(:old_and_online)
      Application.take_old_statuses_offline
    end

    context "when some old statuses are still online" do
      it "gets the access token" do
        Authentication.should_receive(:access_token)
        Application.take_old_statuses_offline
      end

      it "takes each of the old but still online statuses offline" do
        old_online_statuses.each do |s|
          s.should_receive(:take_offline).with(access_token)
        end
        Application.take_old_statuses_offline
      end
    end

    context "when there are no old statuses or none are still online" do
      let(:old_online_statuses) { [] }

      it "does not get the access token" do
        Authentication.should_not_receive(:access_token)
        Application.take_old_statuses_offline
      end
    end
  end
end
