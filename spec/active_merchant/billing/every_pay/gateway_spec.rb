require "spec_helper"

describe ActiveMerchant::Billing::EveryPayGateway do
  let(:gateway_options) {{
    gateway_url: "https://igw-demo.every-pay.com/api/v3",
    api_username: "someuser",
    api_secret: "somepassword",
    account_name: "someaccount",
    customer_url: "https://shop.example.com/cart"
  }}
  let(:nonce){ 199371315853919146519086224534557392392 }
  let(:timestamp){ "2019-05-31T09:14:58+03:00" }
  let(:scheme){ ActiveMerchant::Billing::EveryPayApiScheme.new(:make_oneoff_payment) }

  subject{ described_class.new(gateway_options) }

  it "should be present" do
    expect(subject.present?).to be true
  end

  it "should be in test mode" do
    expect(subject.test?).to be true
  end

  describe "gateway initialization options" do
    [:gateway_url, :api_username, :api_secret, :account_name, :customer_url].each do|option|
      it "requires #{option} option" do
        gateway_options.delete(option)
        expect{ described_class.new(gateway_options) }.to raise_error ArgumentError, "Missing required parameter: #{option}"
      end
    end
  end

  describe "API methods" do
    before do
      allow(subject).to receive(:nonce).and_return(nonce)
      allow(subject).to receive(:timestamp).and_return(timestamp)
    end

    describe "#authorize" do
      it "correctly handles successful response", vcr: {cassette_name: :authorize_success} do
        response = subject.authorize(1267, order_reference: "Order #1234", customer_url: "https://httpbin.org/get")

        expect(response.success?).to be true
        expect(response.authorization).to eq "https://igw-demo.every-pay.com/lp/aedf32/ed4dod"
        expect(response.payment_state).to eq ActiveMerchant::Billing::EveryPayApiScheme::PAYMENT_STATE_INITIAL
        expect(response.payment_reference).to eq "db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a"
      end
    end

    describe "#recurring_merchant" do
      it "correctly handles successful response", vcr: {cassette_name: :recurring_merchant_success} do
        response = subject.recurring_merchant(1267, merchant_ip: "127.0.0.1", token: "X",
                                              token_agreement: ActiveMerchant::Billing::EveryPayApiScheme::TOKEN_AGREEMENT_RECURRING)

        expect(response.success?).to be true
        expect(response.authorization).to be nil
        expect(response.payment_state).to eq ActiveMerchant::Billing::EveryPayApiScheme::PAYMENT_STATE_SETTLED
        expect(response.payment_reference).to eq "db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a"
      end
    end

    describe "#recurring_customer" do
      it "correctly handles successful response", vcr: {cassette_name: :recurring_customer_success} do
        response = subject.recurring_customer(1267, order_reference: "#1234", token: "X",
                                              customer_url: "https://httpbin.org/get")

        expect(response.success?).to be true
        expect(response.authorization).to eq "https://igw-demo.every-pay.com/lp/aedf32/ed4dod"
        expect(response.payment_state).to eq ActiveMerchant::Billing::EveryPayApiScheme::PAYMENT_STATE_WAITING_FOR_3DS_RESPONSE
        expect(response.payment_reference).to eq "db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a"
      end
    end

    describe "#capture" do
      it "correctly handles successful response", vcr: {cassette_name: :capture_success} do
        response = subject.capture(1267, payment_reference: "db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a")

        expect(response.success?).to be true
        expect(response.authorization).to be nil
        expect(response.payment_state).to eq ActiveMerchant::Billing::EveryPayApiScheme::PAYMENT_STATE_SETTLED
        expect(response.payment_reference).to eq "db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a"
      end
    end

    describe "#refund" do
      it "correctly handles successful response", vcr: {cassette_name: :refund_success} do
        response = subject.refund(1267, payment_reference: "db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a")

        expect(response.success?).to be true
        expect(response.authorization).to be nil
        expect(response.payment_state).to eq ActiveMerchant::Billing::EveryPayApiScheme::PAYMENT_STATE_REFUNDED
        expect(response.payment_reference).to eq "db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a"
      end
    end

    describe "#void" do
      it "correctly handles successful response", vcr: {cassette_name: :void_success} do
        response = subject.void(payment_reference: "db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a",
                                reason: "unknown reason")

        expect(response.success?).to be true
        expect(response.authorization).to be nil
        expect(response.payment_state).to eq ActiveMerchant::Billing::EveryPayApiScheme::PAYMENT_STATE_VOIDED
        expect(response.payment_reference).to eq "db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a"
      end
    end

    describe "#result" do
      it "correctly handles successful response", vcr: {cassette_name: :result_success} do
        response = subject.result(payment_reference: "db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a")

        expect(response.success?).to be true
        expect(response.authorization).to be nil
        expect(response.message).to eq "SUCCESS"
        expect(response.payment_state).to eq ActiveMerchant::Billing::EveryPayApiScheme::PAYMENT_STATE_SETTLED
        expect(response.payment_reference).to eq "db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a"
      end
    end
  end

  describe "#commit" do
    let(:params) {{
      api_username: subject.options[:api_username],
      account_name: subject.options[:account_name],
      customer_url: "https://httpbin.org/get",
      amount: "0.13",
      nonce: nonce,
      timestamp: timestamp,
      order_reference: "Order #1234"
    }}

    it "correctly handles failed http auth", vcr: {cassette_name: :failed_http_auth} do
      response = subject.commit(:make_oneoff_payment, params)

      expect(response.success?).to be false
      expect(response.authorization).to be nil
      expect(response.error).to eq({
        "message" => "Non parsable response received from the EveryPay API, status code: 401, body: "
      })
      expect(response.payment_state).to eq nil
      expect(response.payment_reference).to eq nil
    end

    it "tries JSON error parsing on errored http status", vcr: {cassette_name: :failed_http_request_with_json_response} do
      response = subject.commit(:make_oneoff_payment, params)

      expect(response.success?).to be false
      expect(response.authorization).to be nil
      expect(response.error).to eq("code"=>4032, "message"=>"Can not be captured")
      expect(response.payment_state).to eq nil
      expect(response.payment_reference).to eq nil
    end

    it "correctly handles response with invalid JSON", vcr: {cassette_name: :invalid_json_response} do
      response = subject.commit(:make_oneoff_payment, params)

      expect(response.success?).to be false
      expect(response.authorization).to be nil
      expect(response.error).to eq({
        "message" => "Non parsable response received from the EveryPay API, status code: 200, body: random data"
      })
      expect(response.payment_state).to eq nil
      expect(response.payment_reference).to eq nil
    end
  end

  describe "#parse" do
    let(:scheme){ ActiveMerchant::Billing::EveryPayApiScheme.new(:make_oneoff_payment) }
    let(:response_body){ {"payment_state" => "good"}.to_json }
    let(:response){ Net::HTTPResponse.new(1.0, "200", "OK") }

    before do
      allow(response).to receive(:body).and_return(response_body)
    end

    context "when response contains valid json" do
      it "returns parsed HTTP response as JSON" do
        allow(scheme).to receive(:successful_response?).with(JSON.parse(response.body)).and_return(true)
        expect(subject.parse(response, scheme)).to eq("payment_state" => "good")
      end

      context "when response JSON contains unsuccessful response for scheme" do
        it "adds error to parsed JSON" do
          allow(scheme).to receive(:successful_response?).with(JSON.parse(response.body)).and_return(false)
          expect(subject.parse(response, scheme)).to eq("error"=>{"message"=>"Unsuccessful response for :make_oneoff_payment API call"}, "payment_state"=>"good")
        end

        it "does not adds error is there is already one within parsed JSON" do
          allow(response).to receive(:body).and_return("{\"error\":{\"code\":4032,\"message\":\"Can not be captured\"}}")
          expect(scheme).to_not receive(:successful_response?)
          expect(subject.parse(response, scheme)).to eq("error"=>{"code"=>4032, "message"=>"Can not be captured"})
        end
      end
    end

    context "when response contains invalid json" do
      let(:response_body){ "asdsad" }

      it "returns JSON describing parsing error" do
        expect(subject.parse(response, scheme)).to eq({
          "error" => {
            "message" => "Non parsable response received from the EveryPay API, status code: 200, body: asdsad"
          }
        })
      end
    end
  end

  describe "#timestamp" do
    it "returns iso8601 datetime" do
      now = DateTime.now
      allow(DateTime).to receive(:now).and_return(now)
      allow(now).to receive(:iso8601).and_return("foo")
      expect(subject.timestamp).to eq "foo"
    end
  end

  describe "#nonce" do
    it "returns random seed" do
      allow(Random).to receive(:new_seed).and_return("foo")
      expect(subject.nonce).to eq "foo"
    end
  end
end
