require 'rails_helper'

describe Api::V1::InvitationsController do

  let(:user) { FactoryGirl.create(:pro_user) }
  let(:result) { JSON.parse(response.body) }
  let!(:invitation) { FactoryGirl.create(:entourage_invitation, invitee: user) }

  describe 'GET index' do
    context "user not signed in" do
      before { get :index }
      it { expect(response.status).to eq(401) }
    end

    context "user signed in" do
      before { get :index, token: user.token }
      it { expect(response.status).to eq(200) }
      it { expect(result).to eq({"invitations"=>[
                                                  {
                                                    "id"=>invitation.id,
                                                    "inviter_id"=>invitation.inviter_id,
                                                    "invitation_mode"=>"SMS",
                                                    "phone_number"=>"+33612345678",
                                                    "entourage_id"=>invitation.invitable_id,
                                                    "accepted"=>false
                                                  }
                                                ]}) }

    end

    context "belongs to entourage" do
      let!(:entourage) { FactoryGirl.create(:entourage) }
      before { FactoryGirl.create(:join_request, user: user, joinable: entourage, status: JoinRequest::ACCEPTED_STATUS) }
      let!(:invitation) { FactoryGirl.create(:entourage_invitation, invitee: user, invitable: entourage ) }
      before { get :index, token: user.token }
      it { expect(result["invitations"][0]["accepted"]).to be true }
    end
  end

  describe "PUT update" do
    context "user not signed in" do
      before { put :update, id: invitation.to_param}
      it { expect(response.status).to eq(401) }
    end

    context "user signed in" do
      context "accept my invite" do
        before { put :update, id: invitation.to_param, token: user.token }
        it { expect(response.status).to eq(204) }
        it { expect(JoinRequest.where(user: invitation.invitee, joinable: invitation.invitable, status: JoinRequest::ACCEPTED_STATUS).count).to eq(1) }
      end

      context "accept another user invite" do
        let!(:invitation) { FactoryGirl.create(:entourage_invitation, invitee: FactoryGirl.create(:public_user)) }
        before { put :update, id: invitation.to_param, token: user.token }
        it { expect(response.status).to eq(403) }
        it { expect(JoinRequest.where(user: invitation.invitee, joinable: invitation.invitable, status: JoinRequest::ACCEPTED_STATUS).count).to eq(0) }
      end
    end
  end

  describe "DELETE destroy" do
    context "user not signed in" do
      before { delete :destroy, id: invitation.to_param}
      it { expect(response.status).to eq(401) }
    end

    context "user signed in" do
      context "refuse my invite" do
        before { delete :destroy, id: invitation.to_param, token: user.token }
        it { expect(response.status).to eq(204) }
        it { expect(JoinRequest.where(user: invitation.invitee, joinable: invitation.invitable, status: JoinRequest::REJECTED_STATUS).count).to eq(1) }
      end

      context "accept another user invite" do
        let!(:invitation) { FactoryGirl.create(:entourage_invitation, invitee: FactoryGirl.create(:public_user)) }
        before { put :update, id: invitation.to_param, token: user.token }
        it { expect(response.status).to eq(403) }
        it { expect(JoinRequest.where(user: invitation.invitee, joinable: invitation.invitable, status: JoinRequest::REJECTED_STATUS).count).to eq(0) }
      end
    end
  end
end