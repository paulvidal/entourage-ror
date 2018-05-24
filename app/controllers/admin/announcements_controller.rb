module Admin
  class AnnouncementsController < Admin::BaseController
    def index
      @announcements =
        Announcement
        .order(position: :asc, created_at: :desc)
        .group_by(&:status)
    end

    def edit
      @announcement = Announcement.find params[:id]
    end

    def update
      @announcement = Announcement.find params[:id]
      if @announcement.update(announcement_params)
        redirect_to [:edit, :admin, @announcement]
      else
        render :edit
      end
    end

    private

    def announcement_params
      params.require(:announcement).permit(:title, :body, :action, :url, :webview, :status, :human_position)
    end
  end
end
