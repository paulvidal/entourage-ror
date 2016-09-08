module V1
  class FeedSerializer
    def initialize(feeds:, user:, include_last_message: false)
      @feeds = feeds
      @user = user
      @include_last_message = include_last_message
    end

    def to_json
      result = feeds.map do |feed|
        if feed.is_a?(Tour)
          {
              type: "Tour",
              data: JSON.parse(V1::TourSerializer.new(feed, {scope: {user: user, include_last_message: include_last_message}, root: false}).to_json),
              heatmap_size: 20
          }
        elsif feed.is_a?(Entourage)
          {
              type: "Entourage",
              data: JSON.parse(V1::EntourageSerializer.new(feed, {scope: {user: user, include_last_message: include_last_message}, root: false}).to_json),
              heatmap_size: 20
          }
        end
      end
      return {"feeds": result}
    end

    private
    attr_reader :feeds, :user, :include_last_message
  end
end