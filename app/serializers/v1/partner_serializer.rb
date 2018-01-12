module V1
  class PartnerSerializer < ActiveModel::Serializer
    attributes :id,
               :name,
               :large_logo_url,
               :small_logo_url,
               :default

    def default
      # perf optimization for the feed: prevent n+1 request
      if scope[:user].default_user_partners.loaded?
        scope[:user].default_user_partners.any? { |up| up.partner_id == object.id }
      else
        scope[:user].partners.include?(object)
      end
    end
  end
end