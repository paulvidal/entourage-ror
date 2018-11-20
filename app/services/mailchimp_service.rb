# frozen_string_literal: true

module MailchimpService
  BASE = "https://%{dc}.api.mailchimp.com/3.0"
  UPDATE_MEMBER = "/lists/%{list_id}/members/%{subscriber_hash}"

  def self.set_interest list:, user:, interest:, value:
    config = Rails.configuration.x.mailchimp
    raise ConfigError, "Mailchimp API key is not set" if config['api_key'].nil?

    dc = config['api_key'].split('-').last
    raise ConfigError, "Mailchimp API key is invalid" if dc.nil?

    list_name = list.to_s
    list = config.dig('lists', list_name) || {}

    raise ConfigError, "ID of list '#{list_name}' not found in Mailchimp config" if list['id'].nil?

    subscriber_hash = Digest::MD5.hexdigest(user.to_s.strip.downcase)

    url = File.join(BASE, UPDATE_MEMBER) % {
      dc: dc,
      list_id: list['id'],
      subscriber_hash: subscriber_hash
    }

    interest = interest.to_s
    interest_id = list.dig('interests', interest)

    raise ConfigError, "ID of interest '#{list_name}/#{interest}' not found in Mailchimp config" if interest_id.nil?

    raise ":value must be a boolean" unless value.in?([true, false])

    response = HTTParty.patch(
      url,
      basic_auth: {password: config['api_key']},
      headers: {'Content-Type' => 'application/json'},
      body: JSON.fast_generate(interests: {interest_id => value}),
    )

    raise ApiError, response unless response.success?

    response.parsed_response
  end

  class ConfigError < ArgumentError
  end

  class ApiError < RuntimeError
    attr_reader :response, :code, :title, :detail

    def initialize response
      payload = JSON.parse(response.body) rescue {}
      @response = payload.presence || response.body
      @code = payload['status'] || response.code
      @title = payload['title'] || response.message
      @detail = payload['detail']
    end

    def message
      @message ||= begin
        message = "#{code} #{title}"
        message = "#{message}: #{detail}" if detail.present?
      end
    end
  end
end
