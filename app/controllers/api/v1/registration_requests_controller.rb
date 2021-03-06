module Api
  module V1
    class RegistrationRequestsController < Api::V1::BaseController
      skip_before_filter :authenticate_user!, only: [:create]

      def create
        validator = RegistrationRequestValidator.new(params: registration_request_params)
        unless validator.valid?
          return render json: {errors: {organization: validator.organization_errors, user: validator.user_errors}}, status: 400
        end

        registration_request = RegistrationRequest.new(status: "pending",
                                                       extra: registration_request_params)
        registration_request.save!

        AdminMailer.registration_request(registration_request.id).deliver_later

        render json: {registration_request: registration_request.as_json}, status: 201
      end

      private

      def registration_request_params
        params.require(:registration_request).permit({organization: [:name, :description, :phone, :address, :local_entity, :email, :website_url, :logo_key]}, {user: [:first_name, :last_name, :email, :phone]})
      end
    end
  end
end
