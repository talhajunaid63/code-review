ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)

require "sidekiq/testing"
require "simplecov"
require "rails/test_help"
require "minitest/rails/capybara"
require "delorean"
require "minitest/reporters"
require "mocha/minitest"
require "action_dispatch/testing/test_process"
require "capybara-screenshot/testunit"
require "chromedriver-helper"
require 'capybara/rails'
require 'capybara/minitest'

Capybara::Screenshot.autosave_on_failure = false

require 'webmock/test_unit'

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: 'chromedriver.storage.googleapis.com'
)

Chromedriver.set_version "2.41"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu) },
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities).tap do |driver|
    driver.browser.manage.window.size = Selenium::WebDriver::Dimension.new(1024, 768)
  end
end

Capybara.javascript_driver = :headless_chrome

Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.default_max_wait_time = 5

AWS.stub!
OmniAuth.config.test_mode = true

module SidekiqMinitestSupport
  def after_teardown
    Sidekiq::Worker.clear_all
    super
  end
end

class MiniTest::Spec
  include SidekiqMinitestSupport
end

class MiniTest::Unit::TestCase
  include SidekiqMinitestSupport
end

module ActiveSupport
  class TestCase
    include CapybaraSelect2
    include CapybaraSelect2::Helpers

    self.use_transactional_tests = false
    fixtures :all
    Rails.application.load_tasks
  end
end

def debug
  save_and_open_page
  screenshot_and_open_image
end

def apply_db_triggers(obj)
  obj.update_column :id, obj.id
end

def apply_all_users_triggers
  apply_all_triggers_for User
end

def apply_all_triggers_for(klass)
  klass.update_all "id = id"
end

# For requesting and authenticating tokens throughout the API
module AuthenticationHelper
  def api_request_token(login_handler)
    @api_response = {}
    post v1_request_token_path,
        headers: { "APP_TOKEN": "test_001" },
        params: {
          "login_handler": login_handler
        },
        xhr: true
    @api_response = JSON.parse(response.body)
  end

  def api_authenticate_token(login_handler, token, params={})
    post v1_authenticate_token_path,
        headers: { "APP_TOKEN": "test_001" },
        params: {
          "login_handler": login_handler, "token": token
        }.merge(params),
        xhr: true
    @api_response = JSON.parse(response.body)
  end

  def trigger_sign_in
    if Capybara.current_driver == :headless_chrome
      page.execute_script('$("#hidden_submit").trigger("click")')
    else
      find("#hidden_submit").click
    end

  end

  def authenticate_user(user, login_handler)
    visit "/login"

    expect(page).must_have_content("Enter your mobile phone")
    within("form#token_request") do
      fill_in("login_handler", with: login_handler)
      trigger_sign_in
    end

    authentication = Authentication.for(login_handler)
    assert_not_nil authentication, "Authentication with login_handler #{login_handler.inspect} not found"

    expect(page).must_have_content "We sent a code to"
    within("form#token_verify") do
      fill_in("token", with: authentication.reload.token)
      trigger_sign_in
    end

    if authentication.users.size > 1
      expect(page).must_have_content 'Select the account you want to login with'
      click_button "Login as #{user.name} (#{user.type})"
    end
  end

  def sign_in(user)
    session[:user_id] = user.id
  end

end

module ApiHelper
  def patch_to_patient(user, params_to_post)
    patch v1_patient_path(user.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": user.authentication_token
        },
        params: params_to_post,
        xhr: true
    @api_response = JSON.parse(response.body)
  end

  def patch_to_provider(user, params_to_post)
    patch v1_provider_path(user.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": user.authentication_token
        },
        params: params_to_post,
        xhr: true
    @api_response = JSON.parse(response.body)
  end

  def patch_to_coordinator(user, params_to_post)
    patch v1_coordinator_path(user.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": user.authentication_token
        },
        params: params_to_post,
        xhr: true
    @api_response = JSON.parse(response.body)
  end

end

module PaymentHelper
  def stripe_helper
    StripeMock.create_test_helper
  end

  def patient_add_payment(patient)
    StripeMock.start
    customer = Stripe::Customer.create(
      email: patient.email,
      source: stripe_helper.generate_card_token(
        exp_year: 2030,
        exp_month: 10
      ),
    )
    StripeMock.stop
    patient.stripe_id = customer.id
    patient.payment_to_database(customer)
    patient.save
    patient.reload
  end

  def organization_add_payment(organization)
    StripeMock.start
    customer = Stripe::Customer.create(
      source: stripe_helper.generate_card_token(
        exp_year: 2030,
        exp_month: 10
      ),
    )
    StripeMock.stop
    organization.stripe_id = customer.id
    organization.save
    organization.reload
  end

end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

module OrgSetupHelper
  include PaymentHelper

  def org_onboarding_setup(phone, step_number)
    org_onboarding_setup(phone, step_number - 1) unless step_number == 1
    self.send("org_onboarding_step_#{step_number}", phone)
  end

  def org_onboarding_step_1(phone)
    visit new_org_setup_path
    first(:link, "Get Started").click
  end

  def org_onboarding_step_2(phone)
    fill_in "org_setup_sign_up[login_handler]", with: phone
    check "terms-checkbox"
    click_button "Request Sign In Code"
  end

  def org_onboarding_step_3(phone)
    fill_in "org_setup_token_confirmation[token]", with: "12345"
    click_button "Confirm"
  end

  def org_onboarding_step_4(phone)
    @professional_plan = organization_plans(:professional_plan)

    # Setting up professional plan with Stripe
    @stripe_professional_plan = stripe_helper.create_plan(:id => 'professional', :amount => 290000, interval: "month")
    @professional_plan.stripe_id = @stripe_professional_plan.id
    @professional_plan.save

    first("#select-subscription-#{@professional_plan.id}").click
  end

  def org_onboarding_step_5(phone)
    within "#new_org_setup_basic_detail" do
      fill_in "org_setup_basic_detail_name", with: "Test Org"
      fill_in "org_setup_basic_detail_description", with: "Test Description Goes Here"
      fill_in "org_setup_basic_detail_zip", with: "90210"
      fill_in "org_setup_basic_detail_phone", with: "5558015555"
      click_button "Create Organization"
    end
    @organization = Organization.find_by(name: "Test Org")
    organization_add_payment(@organization)
  end

  def org_onboarding_step_6(phone)
    click_link "Skip for now"
    click_link "Looks Good"
  end

  def org_onboarding_step_7(phone)
    click_link "Skip for now"
  end

  def org_onboarding_step_8(phone)
    click_button "Save Settings"
  end

  def org_onboarding_step_9(phone)
    click_button "Save Settings"
  end

  def org_onboarding_step_10(phone)
    click_link "Skip for now"
  end

  def org_onboarding_step_11(phone)
    click_button "Choose Plan"
  end
end

module SubscriptionsHelper
  def subscribe_to(plan)
    visit organization_subscriptions_path(@organization)
    expect(page).must_have_content("Subscriptions")
    expect(page).must_have_content("Web based platform")
    first("#select-subscription-#{plan.id}").click
    click_button "Confirm Subscription"
  end
end

module TextMessageHelper
  def stubs_text_message_send_text
    TextMessage.stubs(:send_text)
  end
end

module S3ServiceHelper
  def stubs_generate_presigned_url
    Recordings::S3Service.stubs(:presigned_url)
  end
end

module OpenTokHelper
  def stubs_open_tok_generate_token
    OpenTok::OpenTok.any_instance.stubs(:generate_token)
  end

  def stubs_open_tok_create_session
    session = OpenTok::Session.new(ApplicationConfig["TOK_API_VP8"],  ApplicationConfig["TOK_SECRET_VP8"], '1MX_2A3453095J0TJ30', {})
    OpenTok::OpenTok.any_instance.stubs(:create_session).returns(session)
  end
end

module StripeHelper
  def create_customer(organization)
    customer = Stripe::Customer.create(
      source: stripe_helper.generate_card_token(
        exp_year: 2030,
        exp_month: 10
      ),
    )

    organization.update(stripe_id: customer.id)
    organization
  end

  def create_plan(plan, interval = 'month')
    stripe_professional_plan = stripe_helper.create_plan(id: plan.name, amount: 50000, interval: interval)
    plan.update(stripe_id: stripe_professional_plan.id)
    plan
  end

  def create_subscription(plan, customer)
    Stripe::Subscription.create({
      plan: plan.stripe_id,
      customer: customer.stripe_id
    })
  end
end

module ChosenHelper
  def select_chosen_options(field, options, is_multiple)
    find(field).click
    if is_multiple
      options.each do |option|
        find('.chosen-results .active-result', text: option).click
        find(field).click
      end
    else
      find('.chosen-results .active-result', text: option).click
    end
  end
end
