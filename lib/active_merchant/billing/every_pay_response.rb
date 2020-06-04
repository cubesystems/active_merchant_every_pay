module ActiveMerchant
  module Billing
    class EveryPayResponse < Response
      def initialize json_response
        success = json_response["error"].nil?

        super success,
          success ? 'SUCCESS' : json_response["error"]["message"],
          json_response,
          test: test?,
          authorization: json_response["payment_link"]
      end

      def payment_state
        params["payment_state"]
      end

      def payment_reference
        params["payment_reference"]
      end

      def error
        params["error"]
      end
    end
  end
end
