require "../../spec_helper"

module PBTranslator
  WL_WIDTH_MAX = 1 << WIDTH_LOG2_MAX
  WL_NETWORK_COUNT = 10

  oe_scheme =
    Scheme::MergeSort::Recursive.new(
      Scheme::OEMerge::INSTANCE
    )

  direct_scheme =
    Scheme::MergeSort::Recursive.new(
      Scheme::DirectMerge::INSTANCE
    )

  record WidthCheckingVisitor(I), width : I do
    include Gate::Restriction

    def visit(gate : Gate, *args, **options) : Void
      wires = gate.wires
      unless wires.all? &.<(width)
        raise "Expected wires less than #{width}, got #{wires}"
      end
    end

    def visit(gate : Gate, *args, **options) : Void
      visit(gate, *args, **options)
      yield self
    end

    def visit(layer : OOPLayer.class, *args, **options) : Void
      yield self
    end
  end

  def self.sort(a : Array(Bool))
    a.sort_by { |w| w ? 0 : 1 }
  end

  def self.sort(a)
    a.sort
  end

  def self.each_sample_size(random)
    a =
      Array.new(WL_NETWORK_COUNT) do
        (2 ** (random.next_float * WIDTH_LOG2_MAX)).to_i
      end
    a.sort.each do |size|
      yield size
    end
  end

  def self.test_limits_with_sub_scheme(sub_scheme)
    scheme = Scheme::WidthLimited.new(sub_scheme)
    random = Random.new(SEED)
    each_sample_size(random) do |width|
      visitor = WidthCheckingVisitor.new(width)
      scheme.network(width).visit(visitor, FORWARD)
    end
  end

  def self.test_sorting_with_sub_scheme(sub_scheme, visitor_factory)
    scheme = Scheme::WidthLimited.new(sub_scheme)
    random = Random.new(SEED)
    each_sample_size(random) do |width|
      a = Array.new(width) { yield random }
      b = a.clone
      c = sort(a)
      visitor = visitor_factory.new(b)
      scheme.network(width).visit(visitor, FORWARD)
      b.should eq(c)
    end
  end

  describe Scheme::WidthLimited do
    it "trims oe merge sorting networks to within limits" do
      test_limits_with_sub_scheme(oe_scheme)
    end

    it "trims direct merge sorting networks to within limits" do
      test_limits_with_sub_scheme(direct_scheme)
    end

    it "sorts with the help of oe merge sorting networks" do
      test_sorting_with_sub_scheme(oe_scheme, Visitor::ArraySwap, &.next_float)
    end

    it "sorts with the help of direct merge sorting networks" do
      test_sorting_with_sub_scheme(direct_scheme, Visitor::ArrayLogic, &.next_bool)
    end
  end
end
