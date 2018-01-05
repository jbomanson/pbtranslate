require "../../spec_helper"

include PBTranslate

describe "PBTranslate::Network#to_network_reverse" do
  it "reverses visitor.way" do
    network = WayNetwork.new
    reverse = network.to_network_reverse
    visitor = Visitor::Noop::INSTANCE
    network.host_reduce(visitor.going(FORWARD), nil).should eq(FORWARD)
    network.host_reduce(visitor.going(BACKWARD), nil).should eq(BACKWARD)
    reverse.host_reduce(visitor.going(FORWARD), nil).should eq(BACKWARD)
    reverse.host_reduce(visitor.going(BACKWARD), nil).should eq(FORWARD)
  end
end

private struct WayNetwork
  include Network

  def host_reduce(visitor, memo)
    visitor.way
  end
end
