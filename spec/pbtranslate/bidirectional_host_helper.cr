module BidirectionalHostHelper
  extend self

  def it_works_predictably_in_reverse(network_factory)
    it "works predictably when used regularly and then in reverse" do
      network = network_factory.call
      expected = network.gates_with_options.to_a
      received = network.to_network_reverse.gates_with_options.to_a.reverse
      expected.map(&.first).should eq(received.map(&.first))
      expected.map(&.last).should eq(received.map(&.last))
    end

    it "works predictably when used in reverse and then regularly" do
      network = network_factory.call
      received = network.to_network_reverse.gates_with_options.to_a.reverse
      expected = network.gates_with_options.to_a
      expected.map(&.first).should eq(received.map(&.first))
      expected.map(&.last).should eq(received.map(&.last))
    end
  end
end
