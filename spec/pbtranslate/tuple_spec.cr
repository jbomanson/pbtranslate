require "../spec_helper"

describe Object do
  context "#pbtranslate_reduce_with_receiver" do
    it "works when concatenating arrays in a tuple" do
      {[1], ["x"]}
        .pbtranslate_reduce_with_receiver(Adder.new, [] of NoReturn)
        .should eq([1, "x"])
    end

    it "works when concatenating tuples in a tuple" do
      sum =
        { {1}, {"x"} }.pbtranslate_reduce_with_receiver(Adder.new, Tuple.new)
      sum.should eq({1, "x"})
      typeof(sum).should eq(Tuple(Int32, String))
    end
  end
end

private struct Adder
  def call(memo, element)
    memo + element
  end
end
