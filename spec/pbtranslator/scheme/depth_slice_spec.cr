require "../../spec_helper"

include PBTranslator

scheme =
  DepthTracking::Scheme.new(
    Scheme::MergeSort::Recursive.new(
      Scheme::OEMerge::INSTANCE
    )
  )

struct RecordingVisitor
  getter array

  @array = Array(Array(Distance)).new

  def visit_gate(g, *args, **options) : Nil
    @array << g.wires.to_a
  end
end

describe Scheme::DepthSlice do
  it "works correctly when partitioning a network in two" do
    random = Random.new(SEED)
    (Distance.new(0)..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      depth = scheme.network(Width.from_log2(width_log2)).network_depth
      point = depth <= 1 ? Distance.new(0) : random.rand(Distance.new(1)...depth)

      scheme_a = Scheme::DepthSlice.new(scheme: scheme, range_proc: ->(width : Width::Pw2, depth: Distance) { Distance.new(0)...point })
      scheme_b = Scheme::DepthSlice.new(scheme: scheme, range_proc: ->(width : Width::Pw2, depth: Distance) { point...depth })

      visitor_x = RecordingVisitor.new
      visitor_y = RecordingVisitor.new

      scheme.network(Width.from_log2(width_log2)).host(visitor_x, FORWARD)

      scheme_a.network(Width.from_log2(width_log2)).host(visitor_y, FORWARD)
      scheme_b.network(Width.from_log2(width_log2)).host(visitor_y, FORWARD)

      visitor_x.array.sort.should eq(visitor_y.array.sort)
    end
  end
end
