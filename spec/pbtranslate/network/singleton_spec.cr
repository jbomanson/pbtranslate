require "../../bidirectional_host_helper"
require "../../spec_helper"

private NETWORK = Network.singleton("gate", level: Distance.new(0))

describe "PBTranslate::Network.singleton" do
  it "works" do
    NETWORK
      .gates_with_options
      .to_a
      .should eq([{"gate", {level: Distance.new(0)}}])
  end

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    NETWORK
  }
end
