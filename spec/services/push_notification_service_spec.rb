require 'rails_helper'

describe PushNotificationService, type: :service do
  describe '#send_notification' do
    let!(:android_notification_service) { spy('android_notification_service') }
    let!(:ios_notification_service) { spy('ios_notification_service') }
    let!(:user_app1) { FactoryGirl.create :user_application, device_family: UserApplication::ANDROID, push_token: 'token 1' }
    let!(:user_app2) { FactoryGirl.create :user_application, device_family: UserApplication::IOS, push_token: 'token 2' }
    let!(:user) { FactoryGirl.create(:pro_user) }
    let!(:sender) { 'sender' }
    let!(:object) { 'object' }
    let!(:content) { 'content' }
    before { UserServices::UnreadMessages.any_instance.stub(:number_of_unread_messages) { 1 } }
    subject! { PushNotificationService.new(android_notification_service, ios_notification_service).send_notification(sender, object, content, User.all) }
    it { expect(android_notification_service).to have_received(:send_notification).with(sender, object, content, user_app1.push_token, user.community.slug, {}, 1) }
    it { expect(ios_notification_service).to have_received(:send_notification).with(sender, object, content, user_app2.push_token, user.community.slug, {}, 1) }
  end
  describe '#send_notification_android_only' do
    let!(:android_notification_service) { spy('android_notification_service') }
    let!(:ios_notification_service) { spy('ios_notification_service') }
    let!(:user_app) { FactoryGirl.create :user_application, device_family: UserApplication::ANDROID, push_token: 'token 1' }
    let!(:user) { FactoryGirl.create(:pro_user) }
    let!(:sender) { 'sender' }
    let!(:object) { 'object' }
    let!(:content) { 'content' }
    before { UserServices::UnreadMessages.any_instance.stub(:number_of_unread_messages) { 1 } }
    subject! { PushNotificationService.new(android_notification_service, ios_notification_service).send_notification(sender, object, content, User.all) }
    it { expect(android_notification_service).to have_received(:send_notification).with(sender, object, content, user_app.push_token, user.community.slug, {}, 1) }
  end
  describe '#send_notification_ios_only' do
    let!(:android_notification_service) { spy('android_notification_service') }
    let!(:ios_notification_service) { spy('ios_notification_service') }
    let!(:user_app) { FactoryGirl.create :user_application, device_family: UserApplication::IOS, push_token: 'token 2' }
    let!(:user) { FactoryGirl.create(:pro_user) }
    let!(:sender) { 'sender' }
    let!(:object) { 'object' }
    let!(:content) { 'content' }
    before { UserServices::UnreadMessages.any_instance.stub(:number_of_unread_messages) { 1 } }
    subject! { PushNotificationService.new(android_notification_service, ios_notification_service).send_notification(sender, object, content, User.all) }
    it { expect(ios_notification_service).to have_received(:send_notification).with(sender, object, content, user_app.push_token, user.community.slug, {}, 1) }
  end
  describe '#send_notification_4ios_tokens' do
    let!(:android_notification_service) { spy('android_notification_service') }
    let!(:ios_notification_service) { spy('ios_notification_service') }
    let!(:user_app1) { FactoryGirl.create :user_application, device_family: UserApplication::IOS, push_token: 'token 1' }
    let!(:user_app2) { FactoryGirl.create :user_application, device_family: UserApplication::IOS, push_token: 'token 2' }
    let!(:user_app3) { FactoryGirl.create :user_application, device_family: UserApplication::IOS, push_token: 'token 3' }
    let!(:user_app4) { FactoryGirl.create :user_application, device_family: UserApplication::IOS, push_token: 'token 4' }
    let!(:user) { FactoryGirl.create(:pro_user) }
    let!(:sender) { 'sender' }
    let!(:object) { 'object' }
    let!(:content) { 'content' }
    before { UserServices::UnreadMessages.any_instance.stub(:number_of_unread_messages) { 1 } }
    subject! { PushNotificationService.new(android_notification_service, ios_notification_service).send_notification(sender, object, content, User.all) }
    it { expect(ios_notification_service).to have_received(:send_notification).with(sender, object, content, user_app4.push_token, user.community.slug, {}, 1) }
    it { expect(ios_notification_service).to have_received(:send_notification).with(sender, object, content, user_app2.push_token, user.community.slug, {}, 1) }
    it { expect(ios_notification_service).to have_received(:send_notification).with(sender, object, content, user_app3.push_token, user.community.slug, {}, 1) }
  end
end
