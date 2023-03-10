Rails.application.configure do
  config.after_initialize do
    Bullet.enable        = true
    Bullet.alert         = true
    Bullet.bullet_logger = true
    Bullet.console       = true
  # Bullet.growl         = true
    Bullet.rails_logger  = true
    Bullet.add_footer    = true
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # 2020/10/21 latter_opener導入のために、trueに変更した。
  config.action_mailer.perform_caching = true
  # 2020/10/21 同上機能
  config.action_mailer.delivery_method = :letter_opener_web
  # config.action_mailer.delivery_method = :test
  #
  #開発環境でも実際にメールを送りたい場合は下を利用。実際に送らない場合は下をコメントアウトし、上の:testの一行を採用する。
  #ActionMailer::Base.delivery_method = :smtp
  #ActionMailer::Base.smtp_settings = {
  #    address: 'smtp.gmail.com',
  #    domain: 'gmail.com',
  #    port: ENV['SMTP_PORT'],
  #    user_name: ENV['SMTP_USER_NAME'],
  #    password:  ENV['SMTP_PASSWORD'],
  #    authentication: 'plain',
  #    enable_starttls_auto: true
  #}

  host = "localhost:3000"
  #config.action_mailer.default_url_options = { :host => host }
  config.action_mailer.default_url_options = { host: host, protcol: "http" }
  #config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  # ref: https://qiita.com/daik/items/41a9bc8dec5ccec37f40
  Rails.application.routes.default_url_options[:host] = host
  #routes.default_url_options[:host] = 'localhost:3000'

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  # Rails 6でngrokを利用するために必要 ref: https://qiita.com/suketa/items/f00570e6f171cb987ddd
  config.hosts << '.ngrok.io'
end
