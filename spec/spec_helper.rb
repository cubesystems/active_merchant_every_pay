$:.unshift File.dirname(__FILE__) + '/../lib'

require "rubygems"
require "bundler/setup"
require "logger"
require "vcr"
require 'webmock/rspec'
require 'pry'
require 'simplecov'
require 'coveralls'

Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start do
  add_filter 'spec'
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {record: :once, match_requests_on: [:uri, :method, :body]}
end

require "active_merchant_every_pay"

ActiveMerchant::Billing::Base.mode = :test
ActiveMerchant::Billing::EveryPayGateway.ssl_strict = true
ActiveMerchant::Billing::EveryPayGateway.logger = Logger.new(STDOUT)
ActiveMerchant::Billing::EveryPayGateway.logger.level = Logger::WARN
