# coding: utf-8

require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

require "capybara/rails"
require "fileutils"

class AcceptanceTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include FileUtils

  SCREENSHOTS_DIR = "screenshot"

  self.use_transactional_fixtures = false

  setup do
    save_and_invalidate_proxy_settings

    Capybara.register_driver :selenium_firefox do |app|
      Capybara::Selenium::Driver.new(app, browser: :firefox)
    end
    Capybara.register_driver :selenium_ie do |app|
      Capybara::Selenium::Driver.new(app, browser: :internet_explorer)
    end
    #Capybara.default_driver = :rack_test
    #Capybara.default_driver = :selenium
    Capybara.default_driver = :selenium_firefox
    #Capybara.default_driver = :selenium_ie

    Capybara.default_wait_time = 60
    DatabaseCleaner.strategy = :transaction
    page.driver.browser.manage.window.maximize
  end

  teardown do
    #Capybara.reset!
    #Capybara.reset_sessions!
    #Capybara.use_default_driver
    DatabaseCleaner.clean

    restore_proxy_settings
  end

  private
  def visit_root
    visit root_path
    assert_equal new_user_session_path, current_path
  end

  def sign_in(userid, password)
    visit_root
    fill_in "user_userid", with: userid
    fill_in "user_password", with: password
    click_button "ログイン"
    assert_equal root_path, current_path
  end

  def sign_out
    click_link "ログアウト"
    assert_equal new_user_session_path, current_path
  end

  def save_screenshot(fname)
    unless Capybara.default_driver == :rack_test
      mkdir_p SCREENSHOTS_DIR
      super(File.join(SCREENSHOTS_DIR, fname))
    end
  end

  def nth_tag(tag, nth)
    find "#{tag}:nth-of-type(#{nth})"
  end

  def save_and_invalidate_proxy_settings
    @lower_http_proxy  = ENV.delete("http_proxy")
    @upper_http_proxy  = ENV.delete("HTTP_PROXY")
    @lower_https_proxy = ENV.delete("https_proxy")
    @upper_https_proxy = ENV.delete("HTTPS_PROXY")
  end

  def restore_proxy_settings
    @lower_http_proxy  and ENV["http_proxy"]  = @lower_http_proxy
    @upper_http_proxy  and ENV["HTTP_PROXY"]  = @upper_http_proxy
    @lower_https_proxy and ENV["https_proxy"] = @lower_https_proxy
    @upper_https_proxy and ENV["HTTPS_PROXY"] = @upper_https_proxy
  end
end
