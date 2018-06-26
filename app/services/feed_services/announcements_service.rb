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
        feeds.insert(position, announcement.feed_object)
      end

      [feeds, @metadata]
    end

    private

    def select_announcements
      announcements = []

      return announcements unless user.community == :entourage

      onboarding_announcement = Onboarding::V1.announcement_for(area, user: user)

      if onboarding_announcement
        announcements.push onboarding_announcement
        @metadata.merge!(onboarding_announcement: true, area: area)
      else
        announcements.push Announcement.new(
          id: 11,
          title: with_first_name("n'attendez plus pour agir !"),
          body: "Conseils, rencontres, idées d'action auprès des SDF... Passez à l'action en discutant avec vos voisins solidaires.",
          action: "J'agis",
          author: User.find_by(email: "guillaume@entourage.social"),
          webview: true,
          position: 1
        )
      end

      announcements.push Announcement.new(
        id: 3,
        title: with_first_name("ne manquez pas les actions autour de vous !"),
        body: "Définissez votre zone d'action pour être tenu(e) informé(e) des actions dans votre quartier.",
        action: "Définir ma zone",
        author: User.find_by(email: "guillaume@entourage.social"),
        webview: true,
        position: 5
      )

      announcements
    end

    def with_first_name text
      if first_name.present?
        "#{first_name}, #{text}"
      else
        text.capitalize
      end
    end

    def first_name
      @first_name ||=
        (user.first_name || "")
        .scan(/[[:alpha:]]+|[^[:alpha:]]+/)
        .map(&:capitalize)
        .join
        .strip
        .presence
    end
  end
end
