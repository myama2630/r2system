R2::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  
  # for Devise
  config.assets.initialize_on_precompile = false
  
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # メール送信機能
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.raise_delivery_errors = true

  # gmail用の定義
  #config.action_mailer.smtp_settings = {
  #  :address => 'smtp.gmail.com',
  #  :port => 587,
  #  :domain => 'localhost',
  #  :authentication => :login,
  #  :user_name => 'xxx@gmail.com',
  #  :password  => 'ppppppp'
  #}

  # ローカルテスト用の定義
  config.action_mailer.smtp_settings = {
    :address => ENV['MAIL_ADDRESS'],
    :port => 25,
    :domain => 'localhost',
    :authentication => :login,
    :user_name => ENV['MAIL_USER'],
    :password  => ENV['MAIL_PASSWORD']
    }
  
  
end
