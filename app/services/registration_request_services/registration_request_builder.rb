module RegistrationRequestServices
  class RegistrationRequestBuilder
    def initialize(registration_request:)
      @registration_request = registration_request
    end

    def validate!
      organization = Organization.new(registration_request.extra["organization"].except("logo_key"))
      builder = UserServices::UserBuilder.new(params:registration_request.extra["user"], organization:organization)

      ActiveRecord::Base.transaction do
        organization.save!
        builder.create(send_sms: true) do |on|
          on.create_success do |user|
            registration_request.update(status: "validated")
            MemberMailer.registration_request_accepted(user)
          end

          on.create_failure do |user|
          end
        end
      end
    end

    private
    attr_reader :registration_request
  end
end