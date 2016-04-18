module V1
  class JoinRequestSerializer < ActiveModel::Serializer
    attributes :id,
               :email,
               :display_name,
               :status,
               :message,
               :requested_at

    def id
      object.user.id
    end

    def email
      object.user.email
    end

    def requested_at
      object.created_at
    end

    def display_name
      "#{object.user.first_name} #{object.user.last_name}" if [object.user.first_name, object.user.last_name].compact.present?
    end
  end
end