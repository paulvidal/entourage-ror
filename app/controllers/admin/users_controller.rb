module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [:show, :messages, :edit, :update, :block, :unblock, :banish, :validate, :experimental_pending_request_reminder]

    def index
      @users = current_user.community.users.includes(:organization).order("last_name ASC").page(params[:page]).per(25)
    end

    def show
      redirect_to edit_admin_user_path(user)
    end

    def messages
      messages =
        @user.conversation_messages
        .where(messageable_type: :Entourage)
        .select("created_at, content, messageable_id as entourage_id")

      messages +=
        @user.entourages
        .select("created_at, description as content, id as entourage_id")

      @entourage_messages =
        messages
        .group_by(&:entourage_id)
        .sort_by { |_, ms| ms.map(&:created_at).max }
        .reverse

      @entourages = Hash[Entourage.where(id: @entourage_messages.map(&:first)).map { |e| [e.id, e] }]
    end

    def edit
    end

    def new
      @user = new_user
    end

    def create
      if user_params[:organization_id].present?
        organization = Organization.find(user_params[:organization_id])
        builder = UserServices::ProUserBuilder.new(params: user_params, organization: organization)
      else
        builder = UserServices::PublicUserBuilder.new(params: user_params, community: community)
      end

      builder.create(send_sms: params[:send_sms].present?) do |on|
        on.success do |user|
          return redirect_to admin_users_path, notice: "utilisateur créé"
        end

        on.invalid_phone_format do
          @user = new_user
          @user.assign_attributes(user_params)
          @user.errors.add(:phone)
        end

        on.duplicate { |user| @user = user }
        on.failure   { |user| @user = user }
      end

      # if we reach here, there was an error
      render :new
    end

    def update
      if !user.pro? && user_params[:organization_id].present?
        user.user_type = 'pro'
        user.organization_id = user_params[:organization_id]
      end

      email_prefs_success = EmailPreferencesService.update(
        user: user, preferences: (params[:email_preferences] || {}))

      user.assign_attributes(user_params)
      UserService.sync_roles(user)

      moderation = user.moderation || user.build_moderation
      moderation.assign_attributes(moderation_params)

      # the browser can transform \n to \r\n and push the text over the
      # 200 char limit.
      user.about.gsub!(/\r\n/, "\n")

      saved = false
      ActiveRecord::Base.transaction do
        user.save! if user.changed?
        moderation.save! if moderation.changed?
        saved = true
      end

      if email_prefs_success && saved
        redirect_to [:admin, user], notice: "utilisateur mis à jour"
      else
        flash.now[:error] = "Erreur lors de la mise à jour"
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

    def block
      @user.block!
      redirect_to [:admin, @user], flash: { success: "Utilisateur bloqué" }
    end

    def unblock
      @user.unblock!
      redirect_to [:admin, @user], flash: { success: "Utilisateur débloqué" }
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

    def experimental_pending_request_reminder
      reminders = @user.experimental_pending_request_reminders
      last_reminder_at = reminders.maximum(:created_at)
      reminders.create! if last_reminder_at.nil? || !last_reminder_at.today?
      redirect_to :back, flash: { _experimental_pending_request_reminder_created: 1 }
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
      @users << UserServices::FakeUser.new.user_quitting_tour(tour: ongoing_tour)
      render :fake
    end

    private
    attr_reader :user

    def set_user
      @user = current_user.community.users.find(params[:id])
    end

    def new_user
      User.new(community: current_user.community, user_type: :public)
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :sms_code, :phone, :organization_id, :use_suggestions, :about, :accepts_emails, :targeting_profile, :partner_id)
    end

    def moderation_params
      params.require(:user_moderation).permit(
        :skills, :expectations, :acquisition_channel
      )
    end
  end

end
