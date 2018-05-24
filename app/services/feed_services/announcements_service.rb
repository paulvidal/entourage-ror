module FeedServices
  class AnnouncementsService
    def initialize(feeds:, user:, page:, area:)
      @feeds = feeds
      @user = user
      @page = page.try(:to_i) || 1
      @area = area
      @metadata = {}
    end

    attr_reader :user, :page, :area

    def feeds
      return [@feeds, @metadata] if page != 1

      announcements = select_announcements

      return [@feeds, @metadata] if announcements.empty?

      feeds = @feeds.to_a

      announcements.each do |announcement|
        position = [feeds.length, announcement.position].min
        feeds.insert(position, announcement.feed_object(user: user))
      end

      [feeds, @metadata]
    end

    private

    def select_announcements
      announcements = {}

      Announcement.where(status: :active).each { |a| announcements[a.position] = a }

      if user.admin?
        Announcement.where(status: :test).each { |a| announcements[a.position] = a }
      end

      onboarding_announcement = Onboarding::V1.announcement_for(area, user: user)
      if onboarding_announcement
        announcements[onboarding_announcement.position] = onboarding_announcement
        @metadata.merge!(onboarding_announcement: true, area: area)
      end

      announcements.sort_by(&:first).map(&:last)
    end
  end
end
