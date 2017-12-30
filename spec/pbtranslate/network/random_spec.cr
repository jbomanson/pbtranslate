require "../../spec_helper"

include PBTranslate
include Gate::Restriction

allowed_mean_square_error = 0.01

private SEED = SpecHelper.file_specific_seed

private def pick_depth(w : Width)
  Distance.new(10) * w.log2ceil
end

describe Network::Random do
  it "returns consistent write counts" do
    random = Random.new(SEED)
    (Distance.new(0)..WIDTH_LOG2_MAX).each do |width_log2|
      w = Width.from_log2(width_log2)
      n = Network::Random.new(random: random, width: w, depth: pick_depth(w))
      x = n.network_write_count
      v = VisitCallCounter.new
      n.host(v)
      y = v.wire_count(Comparator, InPlace)
      y.should eq(x)
    end
  end

  it "represents some networks that at least almost sort" do
    random = Random.new(SEED)
    (Distance.new(0)..WIDTH_LOG2_MAX).each do |width_log2|
      w = Width.from_log2(width_log2)
      a = Array.new(w.value) { random.rand }
      b = a.clone
      c = a.sort
      n = Network::Random.new(random: random, width: w, depth: pick_depth(w))
      v = Visitor::ArraySwap.new(b)
      n.host(v)
      f = b.zip(c).reduce(0.0) { |memo, (x, y)| d = x - y; memo + d * d }
      g = allowed_mean_square_error * w.value
      f.should be < g
    end
  end
end
