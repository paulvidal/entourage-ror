# frozen_string_literal: true

# https://support.iraiser.eu/projects/documentation-api/wiki/API
module IraiserService
  BASE = "https://data.iraiser.eu"
  DATE_FORMAT = "%Y-%m-%d"
  CONTACTS = "/contacts/fromDate/%{from}/toDate/%{to}/campaignIds/%{campaigns}/page/%{page}/maxResults/%{limit}/?selector=ONLY_DONATIONS"

  def self.get_donors since: 1.day.ago
    login, key = ENV['IRAISER_CREDENTIALS'].split(':')
    timestamp = Time.now.to_i
    token = Digest::MD5.hexdigest(login + key + timestamp)

    url = File.join(BASE, CONTACTS) % {
      from: since.strftime(DATE_FORMAT),
      to: Time.zone.now.strftime(DATE_FORMAT), # ? 1.day.from_now ? exclude the /toDate part ?
      campaigns: [].join(','),
      page: 1, # ? 0 ?
      limit: 100 # ?
    }

    reponse = HTTParty.get(
      url,
      headers: {secureLogin: login, secureTimestamp: timestamp, secureToken: token}
    )

    raise ApiError, response unless response.success?

    # elementCount
    # page
    # maxResults

    response.parsed_response
  end

  class ApiError < RuntimeError
    attr_reader :response, :code, :title

    def initialize response
      payload = JSON.parse(response.body) rescue {}
      @response = payload.presence || response.body
      @code = response.code
      @title = response.message
    end

    def message
      @message ||= "#{code} #{title}"
    end
  end
end
