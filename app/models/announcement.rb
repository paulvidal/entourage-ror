class Announcement < ActiveRecord::Base
  # include ActiveModel::Serializers::JSON

  # ATTRIBUTES = [
  #   :id,
  #   :title,
  #   :body,
  #   :action,
  #   :url,
  #   :icon_url,
  #   :author,
  #   :webview,
  #   :position
  # ].freeze
  # attr_accessor *ATTRIBUTES

  # def initialize(attributes={})
  #   self.attributes = attributes
  # end

  # def attributes=(hash)
  #   hash.each do |key, value|
  #     send("#{key}=", value)
  #   end
  # end

  # def attributes
  #   Hash[ATTRIBUTES.map { |key| [key.to_s, send(key)] }]
  # end

  def self.icons
    Dir[Rails.root.join('public/assets/announcements/icons/*.png')].map { |p| File.basename(p, '.png') }
  end

  def human_position
    return if position.nil?
    position + 1
  end

  def human_position= new_position
    self.position = new_position.to_i - 1
  end

  def feed_object
    Feed.new(self)
  end

  class Feed
    def initialize(announcement)
      @feedable = announcement
    end
    attr_reader :feedable
  end
end
