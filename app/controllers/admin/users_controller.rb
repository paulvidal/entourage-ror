module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [:edit, :update, :banish, :validate]

    def index
      @users = User.pro.includes(:organization).order("last_name ASC").page(params[:page]).per(25)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        coordinated_organizations = params.dig(:user, :coordinated_organizations)
        if coordinated_organizations
          @user.coordinated_organizations = Organization.where(id: coordinated_organizations.select {|o| o.present?})
          @user.save
        end
        render :edit, notice: "utilisateur mis à jour"
      else
        render :edit
      end
    end

    def moderate
      @users = if params[:validation_status] == "blocked"
        User.blocked
      else
        User.validated
      end
      @users = @users.where("avatar_key IS NOT NULL").order("updated_at DESC").page(params[:page]).per(25)
    end

    def banish
      @user.block!
      UserServices::Avatar.new(user: user).destroy
      redirect_to moderate_admin_users_path(validation_status: "blocked")
    end

    def validate
      @user.validate!
      redirect_to moderate_admin_users_path(validation_status: "validated")
    end

    def fake
    end

    def generate
      @users = []
      @users << UserServices::FakeUser.new.user_without_tours
      user_with_tours = UserServices::FakeUser.new.user_with_tours
      ongoing_tour = user_with_tours.tours.where(status: "ongoing").first
      @users << user_with_tours
      @users << UserServices::FakeUser.new.user_joining_tour(tour: ongoing_tour)
      @users << UserServices::FakeUser.new.user_accepted_in_tour(tour: ongoing_tour)
      @users << UserServices::FakeUser.new.user_rejected_of_tour(tour: ongoing_tour)
      render :fake
    end

    def search
      @users = User.pro
                   .includes(:organization)
                   .where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
                            search_param,
                            search_param,
                            search_param)
                   .order("last_name ASC")
                   .page(params[:page])
                   .per(25)
      render :index
    end

    private
    attr_reader :user

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :sms_code, :phone, :organization_id)
    end

    def search_param
      "%#{params[:search]}%"
    end
  end
end