raise "HOST should be set" if ENV['HOST'].blank?
API_HOST = ENV['API_HOST'].presence || ENV['HOST']
