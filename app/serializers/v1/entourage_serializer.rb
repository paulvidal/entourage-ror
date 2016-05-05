module V1
  class EntourageSerializer < ActiveModel::Serializer
    attributes :id,
               :status,
               :title,
               :entourage_type,
               :join_status,
               :number_of_unread_messages,
               :number_of_people,
               :created_at
    
    has_one :author
    has_one :location

    def author
      {
          id: object.user.id,
          name: object.user.first_name
      }
    end

    def location
      {
          latitude: object.longitude,
          longitude: object.longitude
      }
    end

    def join_status
      if current_join_request
        current_join_request.status
      else
        "not_requested"
      end
    end

    def number_of_unread_messages
      return nil unless current_join_request
      return object.chat_messages.count if current_join_request.last_message_read.nil?
      object.chat_messages.where("created_at > ?", current_join_request.last_message_read).count
    end

    def current_join_request
      #TODO : replace by sql request ?
      object.join_requests.select {|join_request| join_request.user_id == scope.id}.first
    end
  end
end
