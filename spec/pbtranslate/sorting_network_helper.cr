require "../../spec_helper"

include PBTranslate
include Gate::Restriction

def it_hosts_like_a_sorting_network(scheme, seed, range, rounds)
  it "represents some networks that sort" do
    random = Random.new(seed)
    range.each do |width|
      rounds.times do
        a = Array.new(width.value) { random.rand }
        b = a.clone
        c = a.sort
        visitor = Visitor::ArraySwap.new(b)
        scheme.network(width).host(visitor)
        {a, b}.should eq({a, c})
      end
    end
  end

  it "represents matching numbers of gates going forward and backward" do
    range.each do |width|
      network = scheme.network(width)

      vf, vb = Array.new(2) { VisitCallCounter.new }
      wf, wb = {FORWARD, BACKWARD}

      network.host(vf.going(wf))
      network.host(vb.going(wb))

      ff = vf.count(Comparator, InPlace)
      bb = vb.count(Comparator, InPlace)

      ff.should eq(bb)
    end
  end
end

def it_reports_like_a_sorting_network(scheme, seed, range, rounds)
  it "returns type Distance for #network_depth" do
    typeof(scheme.network(range.first).network_depth).should eq(Distance)
  end

  it "returns type Distance for #network_width" do
    typeof(scheme.network(range.first).network_width).should eq(Distance)
  end

  it "returns type Area for #network_write_count" do
    typeof(scheme.network(range.first).network_write_count).should eq(Area)
  end

  it "returns consistent #network_write_count values" do
    range.each do |width|
      network = scheme.network(width)
      a = network.network_write_count
      visitor = VisitCallCounter.new
      network.host(visitor)
      b = visitor.wire_count(Comparator, InPlace)
      a.should eq(b)
    end
  end

  it "returns consistent #network_depth values" do
    range.each do |width|
      network = scheme.network(width)
      a = network.network_depth
      b = scheme.compute_depth(width)
      a.should eq(b)
    end
  end
end

def it_acts_like_a_sorting_network(scheme, seed, range, rounds)
  it_hosts_like_a_sorting_network(scheme, seed, range, rounds)
  it_reports_like_a_sorting_network(scheme, seed, range, rounds)
end
