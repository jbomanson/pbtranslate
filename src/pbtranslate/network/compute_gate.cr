require "../network"
require "./reduce_gate_feature"

module PBTranslate::Network
  # Computes the cost of gates in this network as defined by a hash that maps
  # gate function names to `Area` values.
  # See `Gate::Restrict` for possible function names.
  def compute_gate_cost(
    function_name_costs : Hash(String, Area) = UNIFORM_FUNCTION_NAME_COSTS
  ) : Area
    reduce_gate_feature(Area.new(0)) do |memo, wire_count, gate_function_name|
      memo + function_name_costs[gate_function_name]
    end
  end

  # Computes the number of gates in this network by visiting all of them.
  def compute_gate_count : Area
    compute_gate_cost(UNIFORM_FUNCTION_NAME_COSTS)
  end

  private UNIFORM_FUNCTION_NAME_COSTS = Hash(String, Area).new(Area.new(1))
end
