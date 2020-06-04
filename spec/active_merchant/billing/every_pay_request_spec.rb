require "spec_helper"

describe ActiveMerchant::Billing::EveryPayRequest do
  let(:params) {{
    api_username: "someuser",
    payment_reference: "xxxx"
  }}
  let(:gateway_options) {{
    api_username: "someuser",
    api_secret: "somepassword",
    account_name: "someaccount",
    gateway_url: "https://igw-demo.every-pay.com/api/v3"
  }}
  let(:scheme){ ActiveMerchant::Billing::EveryPayApiScheme.new(:make_oneoff_payment) }

  subject{ described_class.new(gateway_options, scheme, params) }

  describe "#url" do
    before do
      allow(scheme).to receive(:request_path).and_return("/payments/foo")
    end

    it "supports REST style path params" do
      allow(scheme).to receive(:request_path).and_return("/payments/:payment_reference")
      expect(subject.url).to eq "https://igw-demo.every-pay.com/api/v3/payments/xxxx"
    end

    context "when scheme with POST request given" do
      it "returns url with given path added to gateway url without adding params" do
        allow(scheme).to receive(:get_request?).and_return(false)
        expect(subject.url).to eq "https://igw-demo.every-pay.com/api/v3/payments/foo"
      end
    end

    context "when scheme with GET request given" do
      it "returns url with given path and params added to gateway url" do
        allow(scheme).to receive(:get_request?).and_return(true)
        expect(subject.url).to eq "https://igw-demo.every-pay.com/api/v3/payments/foo?api_username=someuser&payment_reference=xxxx"
      end
    end
  end

  describe "#data" do
    context "when scheme with POST request given" do
      it "returns params encoded as JSON" do
        allow(scheme).to receive(:post_request?).and_return(true)
        expect(subject.data).to eq "{\"api_username\":\"someuser\",\"payment_reference\":\"xxxx\"}"
      end
    end

    context "when scheme with GET request given" do
      it "returns nil" do
        allow(scheme).to receive(:post_request?).and_return(false)
        expect(subject.data).to be nil
      end
    end
  end

  describe "#method" do
    it "returns scheme request method" do
      allow(scheme).to receive(:request_method).and_return(:foo)
      expect(subject.method).to eq :foo
    end
  end

  describe "#headers" do
    it "returns headers with correct content type and http auth" do
      expect(subject.headers).to eq ({
        "Accept" =>  "application/json",
        "Authorization" => "Basic c29tZXVzZXI6c29tZXBhc3N3b3Jk",
        "Content-Type" => "application/json"
      })
    end
  end
end
