require "../../spec_helper"

include PBTranslator
include Gate::Restriction

allowed_mean_square_error = 0.01

seed = SEED ^ __FILE__.hash

def pick_depth(w : Width)
  10_u32 * w.log2ceil
end

describe Network::Random do
  it "returns consistent sizes" do
    random = Random.new(seed)
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      w = Width.from_log2(width_log2)
      n = Network::Random.new(random: random, width: w, depth: pick_depth(w))
      x = n.size
      v = VisitCallCounter.new
      n.host(v, FORWARD)
      y = v.count(Comparator, InPlace)
      y.should eq(x)
    end
  end

  it "represents some networks that at least almost sort" do
    random = Random.new(seed)
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      w = Width.from_log2(width_log2)
      a = Array.new(w.value) { random.rand }
      b = a.clone
      c = a.sort
      n = Network::Random.new(random: random, width: w, depth: pick_depth(w))
      v = Visitor::ArraySwap.new(b)
      n.host(v, FORWARD)
      f = b.zip(c).reduce(0.0) { |memo, (x, y)| d = x - y; memo + d * d }
      g = allowed_mean_square_error * w.value
      f.should be < g
    end
  end
end
