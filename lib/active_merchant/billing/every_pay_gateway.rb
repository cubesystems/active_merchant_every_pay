module ActiveMerchant
  module Billing
    class EveryPayGateway < Gateway

      TEST_GATEWAY_URL = "https://igw-demo.every-pay.com/api/v3"

      self.display_name = "EveryPay"
      self.money_format = :dollars

      def initialize(options = {})
        options[:gateway_url] = TEST_GATEWAY_URL if ActiveMerchant::Billing::Base.test?

        required_options = [:api_username, :api_secret, :account_name, :gateway_url, :customer_url]

        requires!(options, *required_options)
        @options = options
        super
      end

      def authorize(money, params = {})
        params = params.merge(
          api_username: @options[:api_username],
          account_name: @options[:account_name],
          customer_url: @options[:customer_url],
          amount: amount(money),
          nonce: nonce,
          timestamp: timestamp
        )

        commit(:make_oneoff_payment, params)
      end

      def recurring_merchant(money, params = {})
        params = params.merge(
          api_username: @options[:api_username],
          account_name: @options[:account_name],
          amount: amount(money),
          nonce: nonce,
          timestamp: timestamp
        )

        commit(:make_mit_payment, params)
      end

      def recurring_customer(money, params = {})
        params = params.merge(
          api_username: @options[:api_username],
          account_name: @options[:account_name],
          amount: amount(money),
          nonce: nonce,
          timestamp: timestamp
        )

        commit(:make_cit_payment, params)
      end

      def capture(money, params = {})
        params = params.merge(
          api_username: @options[:api_username],
          amount: amount(money),
          nonce: nonce,
          timestamp: timestamp
        )

        commit(:capture_payment, params)
      end

      def refund(money, params = {})
        params = params.merge(
          api_username: @options[:api_username],
          amount: amount(money),
          nonce: nonce,
          timestamp: timestamp
        )

        commit(:refund_payment, params)
      end

      def void(params = {})
        params = params.merge(
          api_username: @options[:api_username],
          nonce: nonce,
          timestamp: timestamp
        )

        commit(:void_payment, params)
      end

      def result(params = {})
        params = params.merge(
          api_username: @options[:api_username],
        )

        commit(:payment_reference, params)
      end

      def timestamp
        DateTime.now.iso8601
      end

      def nonce
        Random.new_seed
      end

      def commit(api_call, params)
        raw_response = nil
        response = nil

        scheme = EveryPayApiScheme.for(api_call)
        scheme.validate_params(params)

        request = EveryPayRequest.new(@options, scheme, params)
        response = raw_ssl_request(request.method, request.url, request.data, request.headers)
        json_response = parse(response, scheme)

        EveryPayResponse.new(json_response)
      end

      def parse(response, scheme)
        begin
          json_response = JSON.parse(response.body)

          if json_response["error"].nil? && !scheme.successful_response?(json_response)
            json_response["error"] = {"message" => "Unsuccessful response for :#{scheme.name} API call"}
          end
        rescue JSON::ParserError
          json_response = {
            "error" => {
              "message" => "Non parsable response received from the EveryPay API, status code: #{response.code}, body: #{response.body}"
            }
          }
        end

        json_response
      end
    end
  end
end
