EveryPay gateway for Active Merchant
=============================================

[![Build Status](https://travis-ci.org/cubesystems/active_merchant_every_pay.svg?branch=master)](https://travis-ci.org/cubesystems/active_merchant_every_pay)
[![Coverage Status](https://coveralls.io/repos/github/cubesystems/active_merchant_every_pay/badge.svg?branch=master)](https://coveralls.io/github/cubesystems/active_merchant_every_pay?branch=master)

## Install

```bash
$ gem install active_merchant_every_pay
```

## Usage

```ruby
require "active_merchant_every_pay"

gateway = ActiveMerchant::Billing::EveryPayGateway.new(
  api_username: "abc12345",
  api_secret: "asdsasdsdasd",
  account_name: "EUR1",
  gateway_url: "https://igw-demo.every-pay.com/api/v3",
  customer_url: "https://shop.example.com/cart"
)

# Authorize for 10 euros and 34 cents
response = gateway.authorize(1034, order_reference: "order #123", email: "client@example.com", customer_ip: "127.0.0.1")

# Use this url to redirect user to merchant portal
response.authorization

# Read status
gateway.result(payment_reference: response.payment_reference)
```

### Gateways
#### SEB
test: `https://igw-demo.every-pay.com/api/v3`   
production: `https://payment.ecommerce.sebgroup.com/api/v3`
