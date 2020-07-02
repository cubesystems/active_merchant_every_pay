# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "active_merchant_every_pay"
  s.version     = "1.0.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["CubeSystems"]
  s.email       = ["info@cubesystems.lv"]
  s.homepage    = "https://github.com/cubesystems/active_merchant_every_pay"
  s.summary     = "EveryPay gateway for Active Merchant"
  s.description = s.summary

  s.files         = Dir.glob("{lib}/**/*") + %w(README.md CHANGELOG.md LICENSE)
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activemerchant", [">= 1.15.0"]

  s.add_development_dependency "pry", ["~> 0.12.2"]
  s.add_development_dependency "rake"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "coveralls", "~>0.8.23"
  s.add_development_dependency "rspec", ["~> 3"]
  s.add_development_dependency "vcr", ["~> 5"]
  s.add_development_dependency "webmock", ["~> 3"]
  s.add_development_dependency "activesupport", [">= 5"]
end
