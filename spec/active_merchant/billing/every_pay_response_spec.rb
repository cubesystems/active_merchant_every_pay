require "spec_helper"

describe ActiveMerchant::Billing::EveryPayResponse do
  let(:response) { {"some_message" => "x"} }
  subject{ described_class.new(response) }

  describe "#initialize" do
    context "when response contains error" do
      let(:response){ {"error" => {"message" => "serious error"}} }

      it "sets success as false" do
        expect(subject.success?).to be false
      end
    end

    context "when response does not contain error" do
      it "sets success when scheme successful response returns true" do
        expect(subject.success?).to be true
      end
    end
  end
end
