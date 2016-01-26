require 'rails_helper'

describe Api::V1::EntouragesController do
  
  describe 'POST create' do
    context "not signed in" do
      before { post :create, entourage: { longitude: 1.123, latitude: 4.567, title: "foo", entourage_type: "help" } }
      it { expect(response.status).to eq(401) }
    end

    context "signed in" do
      let(:user) { FactoryGirl.create(:user) }

      it "creates an entourage" do
        expect {
          post :create, entourage: { longitude: 1.123, latitude: 4.567, title: "foo", entourage_type: "help" }, token: user.token
        }.to change { Entourage.count }.by(1)
      end

      context "valid params" do
        before { post :create, entourage: { longitude: 1.123, latitude: 4.567, title: "foo", entourage_type: "help" }, token: user.token }
        it { expect(JSON.parse(response.body)).to eq({"entourage"=>{"status"=>"open", "title"=>"foo", "entourage_type"=>"help", "number_of_people"=>1, "author"=>{"id"=>user.id, "name"=>"John"}, "location"=>{"latitude"=>1.123, "longitude"=>1.123}}}) }
        it { expect(response.status).to eq(201) }
      end

      context "invalid params" do
        before { post :create, entourage: { longitude: "", latitude: 4.567, title: "foo", entourage_type: "help" }, token: user.token }
        it { expect(JSON.parse(response.body)).to eq({"message"=>"Could not create entourage", "reasons"=>["Longitude doit être rempli(e)"]}) }
        it { expect(response.status).to eq(400) }
      end
    end
  end

  describe 'GET index' do
    context "not signed in" do
      before { get :index }
      it { expect(response.status).to eq(401) }
    end

    context "signed in" do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:user_entourage) { FactoryGirl.create(:entourage, user: user) }
      let!(:entourage) { FactoryGirl.create(:entourage) }
      before { get :index, page: 1, per: 25, token: user.token }

      it "returns only user entourages" do
        expect(JSON.parse(response.body)).to eq({"entourages"=>[{"status"=>"open", "title"=>"foobar", "entourage_type"=>"hand", "number_of_people"=>1, "author"=>{"id"=>user.id, "name"=>"John"}, "location"=>{"latitude"=>2.345, "longitude"=>2.345}}]})
      end
    end
  end
end