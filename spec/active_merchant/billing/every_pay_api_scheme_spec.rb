require "spec_helper"

describe ActiveMerchant::Billing::EveryPayApiScheme do
  subject{ described_class.new(:payment_reference) }

  describe "#validate_params" do
    it "does not raises ArgumentError for valid params" do
      expect{ subject.validate_params(api_username: "x", payment_reference: "y") }.to_not raise_error
    end

    it "raises ArgumentError for missing mandatory request params" do
      expect{ subject.validate_params({}) }.to raise_error ArgumentError, "Missing request params: [:api_username, :payment_reference]"
      expect{ subject.validate_params(api_username: "a", other: "c") }.to raise_error ArgumentError, "Missing request params: [:payment_reference]"
    end

    it "raises ArgumentError for unknown request params" do
      expect{ subject.validate_params(api_username: "a", payment_reference: "b", other: "c") }.to raise_error ArgumentError, "Unknown request params: [:other]"
    end
  end
end
