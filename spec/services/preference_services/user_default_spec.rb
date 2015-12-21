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
      it { expect(PreferenceServices::UserDefault.new(user: user).tour_types).to eq([]) }
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
end