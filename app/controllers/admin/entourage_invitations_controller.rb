module Admin
  class EntourageInvitationsController < Admin::BaseController
    def index
      @entourage_invitations = EntourageInvitation.includes(:inviter).page(params[:page]).per(params[:per])
    end

    def create
      entourage = Entourage.find params[:entourage_id]

      join_request_builder = JoinRequestsServices::JoinRequestBuilder.new(
        joinable: entourage,
        user: current_user,
        message: "Bonjour, je suis #{current_user.first_name} d'Entourage. Je peux sans doute vous aider !"
      )

      join_request_builder.create do |on|
        on.success do |join_request|
          redirect_to admin_entourage_path(entourage), notice: "Vous avez bien rejoint l'entourage."
        end

        on.failure do |join_request|
          redirect_to admin_entourage_path(entourage), notice: 'Could not create entourage participation request'
        end
      end
    end

  end
end
