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

  belongs_to :author, class_name: :User

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

  def feed_object user:
    Feed.new(self, user: user)
  end

  class Feed
    def initialize(announcement, user:)
      substitutions = self.class.substitutions(user: user)
      @feedable = self.class.substitute announcement, substitutions
    end

    attr_reader :feedable

    def self.substitute announcement, substitutions={}
      res = announcement.dup.tap(&:readonly!)
      res.id = announcement.id
      [:title, :body, :url].each do |attribute|
        substitutions.each { |k, v| res[attribute]&.gsub!("{%s}" % k, v.to_s) }
      end
      res
    end

    def self.substitutions user:
      {
        first_name: user.first_name,
        last_name:  user.last_name,
        email:      user.email,
        user_id:    UserServices::EncodedId.encode(user.id),
      }
    end
  end
end
