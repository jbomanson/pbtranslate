require "./gate_options/scheme"
require "./network_or_scheme"

# This module contains schemes for generating networks.
#
# Each scheme represents some class of networks parametrized by some property.
# These networks can generally be instantiated via `#network` or `#network?`
# methods of a scheme.
# These two kinds of network generation methods will raise and return nil
# on errors, respectively.
module PBTranslate::Scheme
  include NetworkOrScheme

  # Returns a potentially uninitialized sample gate and a named tuple of options
  # intended for use in typeof expressions.
  #
  # See `Network#gate_with_options_for_typeof`.
  def gate_with_options_for_typeof
    network_for_typeof.gate_with_options_for_typeof
  end

  # Returns a potentially uninitialized sample argument of the type expected by
  # `network` for use in typeof expressions.
  abstract def network_arguments_for_typeof

  # Returns a potentially uninitialized sample network for use in typeof
  # expressions.
  def network_for_typeof : Network
    network(network_arguments_for_typeof)
  end

  # Implements `#network_arguments_for_typeof`.
  macro delegate_scheme_details_to(*fields)
    def network_arguments_for_typeof
      network_arguments_for_typeof_of({{fields}})
    end
  end

  private def network_arguments_for_typeof_of(fields : Tuple)
    Util.restrict_tuple_uniform(fields).to_a.first.network_arguments_for_typeof
  end
end
