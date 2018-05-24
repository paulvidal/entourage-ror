require 'rails_helper'

describe FeedServices::AnnouncementsService do
  let(:user) { create :public_user }
  let(:area) { nil }

  let!(:active_announcement)     { create :announcement, position: 1, status: :active }
  let!(:test_announcement)       { create :announcement, position: 1, status: :test }
  let!(:onboarding_announcement) { create :announcement, position: 1, status: :inactive }

  before { Onboarding::V1.stub(:announcement) { onboarding_announcement } }

  subject { FeedServices::AnnouncementsService.new(feeds: [], user: user, page: 1, area: area).feeds[0].map(&:feedable) }

  context "default" do
    it { is_expected.to eq [active_announcement] }
  end

  context "onboarding" do
    let(:area) { 'Grenoble' }
    it { is_expected.to eq [onboarding_announcement] }
  end

  context "test" do
    let(:user) { create :public_user, admin: true }
    it { is_expected.to eq [test_announcement] }
  end
end
