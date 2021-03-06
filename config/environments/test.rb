Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_files  = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise errors in `after_rollback`/`after_commit`
  config.active_record.raise_in_transactional_callbacks = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.active_record.logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
  config.active_record.logger.level = Logger::INFO

  # DEV / TEST CREDENTIALS
  ENV["BASIC_ADMIN_USER"] = "admin"
  ENV["BASIC_ADMIN_PASSWORD"] = "3nt0ur4g3"
  ENV["ANDROID_GCM_API_KEY"] = "foobar"

  config.action_mailer.default_url_options = { :host => "localhost" }

  ENV["ENTOURAGE_IMAGES_BUCKET"]="foobar"
  ENV["ENTOURAGE_AVATARS_BUCKET"]="foobar"
  ENV["ENTOURAGE_AWS_ACCESS_KEY_ID"]="foo"
  ENV["ENTOURAGE_AWS_SECRET_ACCESS_KEY"]="bar"

  ENV["MAILCHIMP_LIST_ID"]="foobar"
  ENV["MAILCHIMP_API_KEY"]="foobar-us8"

  ENV["ATD_USERNAME"] = "name"
  ENV["ATD_PASSWORD"] = "password"

  ENV["HOST"]='localhost'

  # Limit slow down due to password hashing
  BCrypt::Engine.cost = BCrypt::Engine::MIN_COST
end
