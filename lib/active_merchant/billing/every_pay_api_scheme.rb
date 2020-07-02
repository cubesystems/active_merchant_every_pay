module ActiveMerchant
  module Billing
    class EveryPayApiScheme
      REQUIRED_PARAM = :required
      OPTIONAL_PARAM = :optional

      TOKEN_AGREEMENT_RECURRING = 'recurring'
      TOKEN_AGREEMENT_UNSCHEDULED = 'unscheduled'

      POST_REQUEST = :post
      GET_REQUEST = :get

      PAYMENT_STATES = [
        PAYMENT_STATE_INITIAL = "initial",
        PAYMENT_STATE_SETTLED = "settled",
        PAYMENT_STATE_VOIDED = "voided",
        PAYMENT_STATE_FAILED = "failed",
        PAYMENT_STATE_REFUNDED = "refunded",
        PAYMENT_STATE_ABANDONED = "abandoned",
        PAYMENT_STATE_AUTHORIZED = "authorized",
        PAYMENT_STATE_CHARGEBACKED = "chargebacked",
        PAYMENT_STATE_WAITING_FOR_3DS_RESPONSE = "waiting_for_3ds_response",
        PAYMENT_STATE_WAITING_FOR_BAV = "waiting_for_bav"
      ]

      SCHEME = {
        make_oneoff_payment: {
          request: {
            method: POST_REQUEST,
            path: "/payments/oneoff",
            params: {
              api_username: REQUIRED_PARAM,
              account_name: REQUIRED_PARAM,
              amount: REQUIRED_PARAM,
              customer_url: REQUIRED_PARAM,
              token_agreement: OPTIONAL_PARAM,
              mobile_payment: OPTIONAL_PARAM,
              order_reference: OPTIONAL_PARAM,
              nonce: REQUIRED_PARAM,
              email: OPTIONAL_PARAM,
              customer_ip: OPTIONAL_PARAM,
              preferred_country: OPTIONAL_PARAM,
              billing_city: OPTIONAL_PARAM,
              billing_country: OPTIONAL_PARAM,
              billing_line1: OPTIONAL_PARAM,
              billing_line2: OPTIONAL_PARAM,
              billing_line3: OPTIONAL_PARAM,
              billing_postcode: OPTIONAL_PARAM,
              billing_state: OPTIONAL_PARAM,
              shipping_city: OPTIONAL_PARAM,
              shipping_country: OPTIONAL_PARAM,
              shipping_line1: OPTIONAL_PARAM,
              shipping_line2: OPTIONAL_PARAM,
              shipping_line3: OPTIONAL_PARAM,
              shipping_code: OPTIONAL_PARAM,
              shipping_state: OPTIONAL_PARAM,
              locale: OPTIONAL_PARAM,
              request_token: OPTIONAL_PARAM,
              token_consent_agreed: OPTIONAL_PARAM,
              timestamp: REQUIRED_PARAM,
              skin_name: OPTIONAL_PARAM,
              integration_details: OPTIONAL_PARAM
            }
          },
          response: {
            successful_states: [PAYMENT_STATE_INITIAL]
          }
        },
        make_mit_payment: {
          request: {
            method: POST_REQUEST,
            path: "/payments/mit",
            params: {
              api_username: REQUIRED_PARAM,
              account_name: REQUIRED_PARAM,
              amount: REQUIRED_PARAM,
              token_agreement: REQUIRED_PARAM,
              merchant_ip: REQUIRED_PARAM,
              order_reference: OPTIONAL_PARAM,
              nonce: REQUIRED_PARAM,
              email: OPTIONAL_PARAM,
              timestamp: REQUIRED_PARAM,
              token: REQUIRED_PARAM,
              integration_details: OPTIONAL_PARAM
            }
          },
          response: {
            successful_states: [PAYMENT_STATE_SETTLED]
          }
        },
        make_cit_payment: {
          request: {
            method: POST_REQUEST,
            path: "/payments/cit",
            params: {
              api_username: REQUIRED_PARAM,
              account_name: REQUIRED_PARAM,
              amount: REQUIRED_PARAM,
              token_agreement: OPTIONAL_PARAM,
              order_reference: REQUIRED_PARAM,
              nonce: REQUIRED_PARAM,
              email: OPTIONAL_PARAM,
              customer_ip: OPTIONAL_PARAM,
              customer_url: REQUIRED_PARAM,
              timestamp: REQUIRED_PARAM,
              token: REQUIRED_PARAM,
              billing_city: OPTIONAL_PARAM,
              billing_country: OPTIONAL_PARAM,
              billing_line1: OPTIONAL_PARAM,
              billing_line2: OPTIONAL_PARAM,
              billing_line3: OPTIONAL_PARAM,
              billing_postcode: OPTIONAL_PARAM,
              billing_state: OPTIONAL_PARAM,
              integration_details: OPTIONAL_PARAM
            }
          },
          response: {
            successful_states: [PAYMENT_STATE_WAITING_FOR_3DS_RESPONSE]
          }
        },
        capture_payment: {
          request: {
            method: POST_REQUEST,
            path: "/payments/capture",
            params: {
              api_username: REQUIRED_PARAM,
              amount: REQUIRED_PARAM,
              payment_reference: REQUIRED_PARAM,
              nonce: REQUIRED_PARAM,
              timestamp: REQUIRED_PARAM,
            }
          },
          response: {
            successful_states: [PAYMENT_STATE_SETTLED]
          }
        },
        refund_payment: {
          request: {
            method: POST_REQUEST,
            path: "/payments/refund",
            params: {
              api_username: REQUIRED_PARAM,
              amount: REQUIRED_PARAM,
              payment_reference: REQUIRED_PARAM,
              nonce: REQUIRED_PARAM,
              timestamp: REQUIRED_PARAM,
            }
          },
          response: {
            successful_states: [PAYMENT_STATE_REFUNDED]
          }
        },
        void_payment: {
          request: {
            method: POST_REQUEST,
            path: "/payments/void",
            params: {
              api_username: REQUIRED_PARAM,
              payment_reference: REQUIRED_PARAM,
              nonce: REQUIRED_PARAM,
              timestamp: REQUIRED_PARAM,
              reason: REQUIRED_PARAM,
            }
          },
          response: {
            successful_states: [PAYMENT_STATE_VOIDED]
          }
        },
        payment_reference: {
          request: {
            method: GET_REQUEST,
            path: "/payments/:payment_reference",
            params: {
              api_username: REQUIRED_PARAM,
              payment_reference: REQUIRED_PARAM
            }
          },
          response: {
            successful_states: [PAYMENT_STATE_SETTLED]
          }
        },
      }

      def self.for api_call
        new(api_call)
      end

      def initialize api_call
        @api_call = api_call
        @scheme = SCHEME.fetch(api_call)
      end

      def successful_response? json_response
        successful_response_states = @scheme.fetch(:response, {}).fetch(:successful_states, [])

        successful_response_states.empty? || successful_response_states.include?(json_response["payment_state"])
      end

      def validate_params params
        mandatory_params = request_params.map{|key, type| key if type == REQUIRED_PARAM }.compact
        all_params = request_params.keys

        missing_params = mandatory_params - params.keys
        raise ArgumentError, "Missing request params: #{missing_params}" if missing_params.any?

        unknown_params = params.keys - request_params.keys
        raise ArgumentError, "Unknown request params: #{unknown_params}" if unknown_params.any?
      end

      def name
        @api_call
      end

      def request_params
         @scheme.fetch(:request).fetch(:params, {})
      end

      def request_method
        @scheme.fetch(:request).fetch(:method)
      end

      def post_request?
        request_method == POST_REQUEST
      end

      def get_request?
        request_method == GET_REQUEST
      end

      def request_path
        @scheme.fetch(:request).fetch(:path)
      end
    end
  end
end
