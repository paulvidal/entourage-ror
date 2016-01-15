module Api
  module V1
    class StatsController < Api::V1::BaseController
      skip_before_filter :authenticate_user!

      def index
        render json: { tours: Tour.count,
                       encounters: Encounter.count,
                       organizations: Organization.count }.to_json
      end
    end
  end
end
