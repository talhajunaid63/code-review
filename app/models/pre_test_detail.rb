class PreTestDetail < ApplicationRecord
  store_accessor :content, :os, :browser, :os_version, :browser_version, :failed_reason

  belongs_to :pre_test, class_name: 'Visit', foreign_key: 'visit_id'
  belongs_to :user

  def browser_info
    [os, os_version, browser, browser_version].compact.join(' ')
  end

  def set_browser_meta_and_attempted_at(browser)
    update(
      os: browser.platform.name,
      os_version: browser.platform.version,
      browser: browser.name,
      browser_version: browser.full_version,
      attempted_at: Time.now
    )
  end

  def pre_test
    Visit.unscoped { super }
  end

  def successful?
    pre_test.success_category_status?
  end
end
