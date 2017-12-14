require "../network/hard_coded"
require "../scheme"

# :nodoc:
module PBTranslate::Scheme::PartialFlexibleSortHardCoded
  include Scheme
  include Scheme::WithArguments(Width::Flexible)
  extend self

  module ::PBTranslate
    # Creates a partial scheme representing a fixed number of good networks.
    def Scheme.partial_flexible_sort_hard_coded : PartialFlexibleSortHardCoded
      PartialFlexibleSortHardCoded
    end
  end

  declare_gate_options

  # The range of width values for which `.network` is defined.
  def width_value_range
    Distance.new(0)..Distance.new(24)
  end

  # Returns a good network of _width_.
  #
  # Raises an error for width values outside of `.width_value_range`.
  def network(width : Width)
    n = network? width
    unless n
      raise "Width #{width.value} is not in #{width_value_range}"
    end
    n
  end

  # Returns a good network of _width_ or nil.
  def network?(width : Width)
    case width.value
    when  0; Network::HardCoded::SORT_00_EMPTY
    when  1; Network::HardCoded::SORT_01_EMPTY
    when  2; Network::HardCoded::SORT_02
    when  3; Network::HardCoded::SORT_03
    when  4; Network::HardCoded::SORT_04
    when  5; Network::HardCoded::SORT_05
    when  6; Network::HardCoded::SORT_06
    when  7; Network::HardCoded::SORT_07
    when  8; Network::HardCoded::SORT_08
    when  9; Network::HardCoded::SORT_09
    when 10; Network::HardCoded::SORT_10
    when 11; Network::HardCoded::SORT_11
    when 12; Network::HardCoded::SORT_12
    when 13; Network::HardCoded::SORT_13
    when 14; Network::HardCoded::SORT_14
    when 15; Network::HardCoded::SORT_15
    when 16; Network::HardCoded::SORT_16
    when 17; Network::HardCoded::SORT_17
    when 18; Network::HardCoded::SORT_18
    when 19; Network::HardCoded::SORT_19
    when 20; Network::HardCoded::SORT_20
    when 21; Network::HardCoded::SORT_21
    when 22; Network::HardCoded::SORT_22
    when 23; Network::HardCoded::SORT_23
    when 24; Network::HardCoded::SORT_24
    end
  end
end
