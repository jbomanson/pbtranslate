require "../../spec_helper"

include PBTranslator
include Gate::Restriction

macro it_passes_as_a_sorting_network(scheme, seed, range, rounds)
  %scheme = {{scheme}}
  %seed = {{seed}}
  %range = {{range}}
  %rounds = {{rounds}}

  it "represents some networks that sort" do
    random = Random.new(%seed)
    %range.each do |width|
      %rounds.times do
        a = Array.new(width.value) { random.rand }
        b = a.clone
        c = a.sort
        visitor = Visitor::ArraySwap.new(b)
        %scheme.network(width).host(visitor, FORWARD)
        {a, b}.should eq({a, c})
      end
    end
  end

  it "returns consistent write counts" do
    %range.each do |width|
      network = %scheme.network(width)
      a = network.network_write_count
      visitor = VisitCallCounter.new
      network.host(visitor, FORWARD)
      b = visitor.wire_count(Comparator, InPlace)
      a.should eq(b)
    end
  end

  it "represents matching numbers of gates going forward and backward" do
    %range.each do |width|
      network = %scheme.network(width)

      vf, vb = Array.new(2) { VisitCallCounter.new }
      wf, wb = {FORWARD, BACKWARD}
      
      network.host(vf, wf)
      network.host(vb, wb)

      ff = vf.count(Comparator, InPlace)
      bb = vb.count(Comparator, InPlace)

      ff.should eq(bb)
    end
  end

  it "returns consistent depths" do
    %range.each do |width|
      network = %scheme.network(width)
      a = network.network_depth
      visitor = PBTranslator::Visitor::Noop::INSTANCE
      nn = DepthTracking::Network.new(network: network, width: width.value)
      nn.host(visitor, FORWARD)
      b = nn.computed_depth
      a.should eq(b)
    end
  end
end
