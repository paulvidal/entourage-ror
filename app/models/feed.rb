class Feed < ActiveRecord::Base
  include FeedsConcern
  reverse_geocoded_by :latitude, :longitude

  # https://github.com/rails/rails/blob/v4.2.10/activerecord/lib/active_record/attributes.rb
  attribute :community, Community::Type.new

  belongs_to :user
  belongs_to :feedable, polymorphic: true
  has_many :join_requests, -> { where("feedable_type = joinable_type") }, foreign_key: :joinable_id, primary_key: :feedable_id

  attr_accessor :current_join_request,
                :number_of_unread_messages,
                :last_chat_message,
                :last_join_request
end
