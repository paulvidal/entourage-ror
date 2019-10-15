module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :authenticate_admin!

    def home
      if current_admin
        redirect_to admin_entourages_path
      else
        redirect_to new_session_path
      end
    end

    def community
      @community ||= begin
        $server_community
      end
    end

    protected

    def ensure_moderator!
      unless current_user.roles.include?(:moderator)
        render text: "Cette action nécessite d'être modérateur", status: :unauthorized
      end
    end
  end
end
