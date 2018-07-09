module Experimental
  # - symbolizes keys for the user-facing representation
  # - casts 'date-time-iso8601' between ActiveSupport::TimeWithZone
  #   and the appropriate representation for SQL comparisons
  #
  # the Hash/JSON needs to have a $id property
  # the $id property must have the format "urn:#{schema_repo}(:...)"
  # `schema_repo` is the `underscore`d name of a class
  # that has a `json_schema` method that returns a schema given an URN
  #
  # e.g.
  #    class Entourage < ActiveRecord::Base
  #      def self.json_schema urn
  #        case urn
  #        when "urn:entourage:metadata"
  #          {
  #            properties: {
  #              starts_at: { format: 'date-time-iso8601' }
  #            }
  #          }
  #        end
  #      end
  #
  #      attribute :metadata, Experimental::JsonbWithSchema.new
  #    end
  #
  #  enables this behavior for the `metadata` jsonb attribute:
  #  accepts writes with string keys, ISO8601 datetimes:
  #    entourage.metadata =   {"starts_at"=>"2018-07-07T19:42:47+02:00",
  #                            "$id"=>"urn:entourage:outing:metadata"}
  #
  #  serializes the date in a format appripriate for SQL comparisons:
  #    # in database:         {"starts_at": "2018-07-07 17:42:42.000000",
  #                            "$id": "urn:entourage:outing:metadata"}
  #
  #  symbolizes keys and casts date to ActiveSupport::TimeWithZone on read:
  #    p entourage.metadata # {:starts_at => Sat, 07 Jul 2018 19:44:51 CEST +02:00,
  #                            :$id =>"urn:entourage:outing:metadata"}
  #
  class JsonbWithSchema < ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Jsonb
    def initialize
      @datetime_properties = {}
    end

    def type_cast_from_database(value)
      # expose the value to the user as a datetime attribute with timezone
      value = super(value)
      value.symbolize_keys!
      datetime_properties(value).each do |property|
        next unless value.key?(property)
        value[property] = timezone_converter.type_cast_from_database(value[property])
      end
      value
    end

    def type_cast_from_user(value)
      # accepts the same values frome the user than a datetime attribute with timezone
      value = value.symbolize_keys
      datetime_properties(value).each do |property|
        next unless value.key?(property)
        value[property] = timezone_converter.type_cast_from_user(value[property])
      end
      super(value)
    end

    def type_cast_for_database(value)
      # writes to the database in the same way that a date is cast
      # this allows
      value = value.symbolize_keys
      datetime_properties(value).each do |property|
        next unless value.key?(property)
        value[property] = connection_adapter.quoted_date(value[property])
      end
      super(value)
    end

    private

    def datetime_properties(value)
      urn = value[:$id]
      return [] if urn.nil?

      @datetime_properties[urn] ||= begin
        schema = urn.to_s.split(':')[1].camelize.safe_constantize&.json_schema(urn)
        schema&.symbolize_keys&.fetch(:properties, [])&.find_all do |_, property|
          property.symbolize_keys[:format] == 'date-time-iso8601'
        end&.map(&:first) || []
      end
    end

    def connection_adapter
      ActiveRecord::Base.connection
    end

    def timezone_converter
      @timezone_converter ||=
        ActiveRecord::AttributeMethods::TimeZoneConversion::TimeZoneConverter.new(
          connection_adapter.type_map.fetch(
            connection_adapter.type_to_sql(:datetime)
          )
        )
    end
  end
end
