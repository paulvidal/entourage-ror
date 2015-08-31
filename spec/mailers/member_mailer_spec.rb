require 'rails_helper'

describe MemberMailer, type: :mailer do
  describe '#tour_report' do
    let!(:tour) { FactoryGirl.create :tour, :filled }
    let!(:mail) { MemberMailer.tour_report(tour) }
    it { expect(mail.from).to eq ['contact@entourage.social'] }
    it { expect(mail.to).to eq [tour.user.email] }
    it { expect(mail.subject).to eq 'Résumé de la maraude' }
    it { expect(mail.body.encoded).to match "Bonjour #{tour.user.first_name}" }
  end
  
  describe '#poi_report' do
    let!(:poi) { create :poi }
    let!(:user) { create :user }
    let!(:message) { 'message' }
    let!(:poi_report_email) { 'report_email' }
    before { ENV["POI_REPORT_EMAIL"] = poi_report_email }
    after { ENV.delete("POI_REPORT_EMAIL") }
    subject { MemberMailer.poi_report(poi, user, message) }
    it { expect(subject.from).to eq ['contact@entourage.social'] }
    it { expect(subject.to).to eq [poi_report_email] }
    it { expect(subject.subject).to eq 'Correction de POI' }
    it { expect(subject.body.encoded).to match "L'utilisateur #{user.full_name} ##{user.id} voudrait soumettre une correction sur le POI #{poi.name} ##{poi.id}" }
    it { expect(subject.body.encoded).to match message }
  end
end