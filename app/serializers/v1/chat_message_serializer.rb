module V1
  class ChatMessageSerializer < ActiveModel::Serializer
    attributes :id,
               :content,
               :user,
               :created_at,
               :message_type,
               :metadata

    def filter(keys)
      keys -= [:metadata] unless object.message_type.in?(['outing', 'status_update'])
      keys
    end

    def user
      {
        id: chat_user.id,
        avatar_url: UserServices::Avatar.new(user: chat_user).thumbnail_url,
        display_name: display_name,
        partner: chat_user.partner.nil? ? nil : V1::PartnerSerializer.new(chat_user.partner, scope: {user: chat_user}, root: false).as_json
      }
    end

    def display_name
      UserPresenter.new(user: object.user).display_name
    end

    def chat_user
      object.user
    end

    def metadata
      object.metadata.except(:$id)
    end
  end
end
