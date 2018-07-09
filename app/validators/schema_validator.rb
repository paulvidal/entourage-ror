class SchemaValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    schema_uri = record.json_schema_uri(attribute)
    value['$id'] = schema_uri
    schema = record.class.json_schema schema_uri
    errors = ::JSON::Validator.fully_validate(schema, value, validate_schema: !Rails.env.production?)

    return if errors.empty?

    errors.each do |error|
      stripped_error = error.gsub(/ in schema \S{36}$/, '')
      record.errors.add(attribute, stripped_error)
    end
  end
end
