class ChatMessage < ActiveRecord::Base
  belongs_to :messageable, polymorphic: true
  belongs_to :user

  validates :messageable_id, :messageable_type, :content, :user_id, presence: true

  scope :ordered, -> { order("created_at ASC") }
  scope :before, -> (before){ where("created_at < ?", before) }
end