require 'rails_helper'

describe Api::V1::Entourages::InvitationsController do

  let(:user) { FactoryGirl.create(:pro_user) }
  let(:entourage) { FactoryGirl.create(:entourage) }
  let(:result) { JSON.parse(response.body) }

  describe 'POST create' do
    context "user not signed in" do
      before { post :create, entourage_id: entourage.to_param }
    end

    context "user signed in" do
      context "valid params" do
        before { post :create, entourage_id: entourage.to_param, invite: {mode: "SMS", phone_number: "+33612345678"}, token: user.token }
        it { expect(EntourageInvitation.count).to eq(1) }
        it { expect(result).to eq({"invite"=>{
                                            "id"=>EntourageInvitation.last.id,
                                            "inviter_id"=>user.id,
                                            "invitation_mode"=>"SMS",
                                            "phone_number"=>"+33612345678",
                                            "entourage_id"=>entourage.id}
                                  }) }
      end

      context "invitation already exists" do
        let(:entourage_invitation) { FactoryGirl.create(:entourage_invitation, invitable: entourage, inviter: user, phone_number: "+33612345678") }
        before { post :create, entourage_id: entourage.to_param, invite: {mode: "SMS", phone_number: "+33612345678"}, token: user.token }
        it { expect(EntourageInvitation.all).to eq([entourage_invitation]) }
      end

      context "inivte to an entourage i'm not part of" do
        #should render 403 error
      end
    end

  end
end