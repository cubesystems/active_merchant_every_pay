module ActiveMerchant
  module Billing
    class EveryPayRequest
      attr_accessor :gateway_options, :scheme, :params

      def initialize gateway_options, scheme, params
        self.gateway_options = gateway_options
        self.scheme = scheme
        self.params = params
      end

      def data
        params.to_json if scheme.post_request?
      end

      def url
        uri = URI(gateway_options.fetch(:gateway_url))
        uri.path += scheme.request_path.gsub(/(:[\w]*)/) {|m| m.gsub(m, params.fetch(m.tr(":", "").to_sym)) }

        uri.query = URI.encode_www_form(params) if scheme.get_request?

        uri.to_s
      end

      def method
        scheme.request_method
      end

      def headers
        {
          "Content-Type" => "application/json",
          "Accept" => "application/json",
          "Authorization" => basic_auth
        }
      end

      def basic_auth
        "Basic " + Base64.strict_encode64("#{gateway_options.fetch(:api_username)}:#{gateway_options.fetch(:api_secret)}")
      end
    end
  end
end
