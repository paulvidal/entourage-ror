require 'rails_helper'

RSpec.describe NewsletterSubscriptionsController, :type => :controller do

  describe "POST create" do

    context "with correct parameters" do

      it "renders 201" do
        newsletter_subscription_attributes = attributes_for(:newsletter_subscription)

        newsletter_subscription = FactoryGirl.create(:newsletter_subscription)
        post 'create', newsletter_subscription: {email: newsletter_subscription_attributes[:email], active: newsletter_subscription_attributes[:active]}, :format => :json
        expect(response.status).to eq(201)
      end

      it "creates new subscription" do
        newsletter_subscription_attributes = attributes_for(:newsletter_subscription)
        newsletter_subscription_count = NewsletterSubscription.count
        post 'create', newsletter_subscription: {email: newsletter_subscription_attributes[:email], active: newsletter_subscription_attributes[:active]}, :format => :json
        expect(NewsletterSubscription.count).to be(newsletter_subscription_count + 1)
      end

    end

    context "with incorrect parameters" do

      it "renders 400" do
        post 'create', newsletter_subscription: {not_email_param: "subscriber@newsletter.com", not_active_param: true}, :format => :json
        expect(response.status).to eq(400)
      end      

    end

  end

end
