require 'rails_helper'

describe PreferenceServices::UserDefault do

  let(:user) { FactoryGirl.create(:user) }

  describe 'snap_to_road' do
    context "true" do
      before { PreferenceServices::UserDefault.new(user: user).snap_to_road = true }
      it { expect(PreferenceServices::UserDefault.new(user: user).snap_to_road).to be true }
    end

    context "false" do
      before { PreferenceServices::UserDefault.new(user: user).snap_to_road = false }
      it { expect(PreferenceServices::UserDefault.new(user: user).snap_to_road).to be false }
    end
  end

  describe 'tour types' do
    context "has tours" do
      before { PreferenceServices::UserDefault.new(user: user).tour_types = ["foo", "bar"] }
      it { expect(PreferenceServices::UserDefault.new(user: user).tour_types).to eq(["foo", "bar"]) }
    end

    context "no tours" do
      it { expect(PreferenceServices::UserDefault.new(user: user).tour_types).to eq(["medical", "barehands", "alimentary"]) }
    end

    context "set no tours" do
      before { PreferenceServices::UserDefault.new(user: user).tour_types = [] }
      it { expect(PreferenceServices::UserDefault.new(user: user).tour_types).to eq([]) }
    end
  end

  describe 'date_range' do
    context "has date range saved" do
      before { PreferenceServices::UserDefault.new(user: user).date_range = "22/11/2015-21/12/2015" }
      it { expect(PreferenceServices::UserDefault.new(user: user).date_range).to eq("22/11/2015-21/12/2015") }
    end

    context "no tours" do
      it { expect(PreferenceServices::UserDefault.new(user: user).date_range).to eq("") }
    end
  end

  describe 'latitude' do
    context "has latitude saved" do
      before { PreferenceServices::UserDefault.new(user: user).latitude = 48.858859 }
      it { expect(PreferenceServices::UserDefault.new(user: user).latitude).to eq(48.858859) }
    end

    context "no latitude" do
      it { expect(PreferenceServices::UserDefault.new(user: user).latitude).to be_nil }
    end
  end

  describe 'longitude' do
    context "has longitude saved" do
      before { PreferenceServices::UserDefault.new(user: user).longitude = 2.34705999 }
      it { expect(PreferenceServices::UserDefault.new(user: user).longitude).to eq(2.34705999) }
    end

    context "no longitude" do
      it { expect(PreferenceServices::UserDefault.new(user: user).longitude).to be_nil }
    end
  end
end