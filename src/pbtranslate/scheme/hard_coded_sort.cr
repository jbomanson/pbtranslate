require "../network/indexable_comparator"
require "../network/wrapper_with_depth"
require "../scheme"

# A collection of good networks of fixed widths.
module PBTranslate::Scheme::HardCodedSort
  include Scheme
  extend self

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
    when  0; NETWORK_00_EMPTY
    when  1; NETWORK_01_EMPTY
    when  2; NETWORK_02
    when  3; NETWORK_03
    when  4; NETWORK_04
    when  5; NETWORK_05
    when  6; NETWORK_06
    when  7; NETWORK_07
    when  8; NETWORK_08
    when  9; NETWORK_09
    when 10; NETWORK_10
    when 11; NETWORK_11
    when 12; NETWORK_12
    when 13; NETWORK_13
    when 14; NETWORK_14
    when 15; NETWORK_15
    when 16; NETWORK_16
    when 17; NETWORK_17
    when 18; NETWORK_18
    when 19; NETWORK_19
    when 20; NETWORK_20
    when 21; NETWORK_21
    when 22; NETWORK_22
    when 23; NETWORK_23
    when 24; NETWORK_24
    end
  end

  private def create(*args, **options)
    n = Network::IndexableComparator.new(*args, **options)
    s = n.scheme
    w = Width.from_value(n.network_width)
    d = s.compute_depth(w)
    nnn = PBTranslate::Network::WrapperWithDepth.new(network: n, network_depth: d)
  end

  private def with_limited_width(network n, width w)
    create(n.wire_pairs.select &.all? &.< w)
  end

  # A trivial network with no gates.
  NETWORK_00_EMPTY =
    create(Array({Distance, Distance}).new, width: Distance.new(0))

  # A trivial network with no gates that reports a width of 1.
  NETWORK_01_EMPTY =
    create(Array({Distance, Distance}).new, width: Distance.new(1))

  # A network generated using the Bose-Nelson algorithm on the website
  # http://pages.ripco.net/~jgamble/nw.html
  NETWORK_02 =
    create(
      [
        {0, 1},
      ]
    )

  # ditto
  NETWORK_03 =
    create(
      [
        {1, 2},
        {0, 2},
        {0, 1},
      ]
    )

  # ditto
  NETWORK_04 =
    create(
      [
        {0, 1},
        {2, 3},
        {0, 2},
        {1, 3},
        {1, 2},
      ]
    )

  # A network generated with "sortnetgen 5 --measure=count --level-factor=1.1".
  NETWORK_05 =
    create(
      [
        {0, 1},
        {2, 3},
        {0, 2},
        {1, 4},
        {1, 2},
        {3, 4},
        {0, 1},
        {2, 3},
        {1, 2},
      ]
    )

  # A network generated using the Bose-Nelson algorithm on the website
  # http://pages.ripco.net/~jgamble/nw.html
  NETWORK_06 =
    create(
      [
        {1, 2},
        {0, 2},
        {0, 1},
        {4, 5},
        {3, 5},
        {3, 4},
        {0, 3},
        {1, 4},
        {2, 5},
        {2, 4},
        {1, 3},
        {2, 3},
      ]
    )

  # ditto
  NETWORK_07 =
    create(
      [
        {1, 2},
        {0, 2},
        {0, 1},
        {3, 4},
        {5, 6},
        {3, 5},
        {4, 6},
        {4, 5},
        {0, 4},
        {0, 3},
        {1, 5},
        {2, 6},
        {2, 5},
        {1, 3},
        {2, 4},
        {2, 3},
      ]
    )

  # ditto
  NETWORK_08 =
    create(
      [
        {0, 1},
        {2, 3},
        {0, 2},
        {1, 3},
        {1, 2},
        {4, 5},
        {6, 7},
        {4, 6},
        {5, 7},
        {5, 6},
        {0, 4},
        {1, 5},
        {1, 4},
        {2, 6},
        {3, 7},
        {3, 6},
        {2, 4},
        {3, 5},
        {3, 4},
      ]
    )

  # A network generated using the "Best" option on the website
  # http://pages.ripco.net/~jgamble/nw.html
  NETWORK_09 =
    create(
      [
        {0, 1},
        {3, 4},
        {6, 7},
        {1, 2},
        {4, 5},
        {7, 8},
        {0, 1},
        {3, 4},
        {6, 7},
        {0, 3},
        {3, 6},
        {0, 3},
        {1, 4},
        {4, 7},
        {1, 4},
        {2, 5},
        {5, 8},
        {2, 5},
        {1, 3},
        {5, 7},
        {2, 6},
        {4, 6},
        {2, 4},
        {2, 3},
        {5, 6},
      ]
    )

  # ditto
  NETWORK_10 =
    create(
      [
        {4, 9},
        {3, 8},
        {2, 7},
        {1, 6},
        {0, 5},
        {1, 4},
        {6, 9},
        {0, 3},
        {5, 8},
        {0, 2},
        {3, 6},
        {7, 9},
        {0, 1},
        {2, 4},
        {5, 7},
        {8, 9},
        {1, 2},
        {4, 6},
        {7, 8},
        {3, 5},
        {2, 5},
        {6, 8},
        {1, 3},
        {4, 7},
        {2, 3},
        {6, 7},
        {3, 4},
        {5, 6},
        {4, 5},
      ]
    )

  # ditto
  NETWORK_11 =
    create(
      [
        {0, 1},
        {2, 3},
        {4, 5},
        {6, 7},
        {8, 9},
        {1, 3},
        {5, 7},
        {0, 2},
        {4, 6},
        {8, 10},
        {1, 2},
        {5, 6},
        {9, 10},
        {1, 5},
        {6, 10},
        {5, 9},
        {2, 6},
        {1, 5},
        {6, 10},
        {0, 4},
        {3, 7},
        {4, 8},
        {0, 4},
        {1, 4},
        {7, 10},
        {3, 8},
        {2, 3},
        {8, 9},
        {2, 4},
        {7, 9},
        {3, 5},
        {6, 8},
        {3, 4},
        {5, 6},
        {7, 8},
      ]
    )

  # ditto
  NETWORK_12 =
    create(
      [
        {0, 1},
        {2, 3},
        {4, 5},
        {6, 7},
        {8, 9},
        {10, 11},
        {1, 3},
        {5, 7},
        {9, 11},
        {0, 2},
        {4, 6},
        {8, 10},
        {1, 2},
        {5, 6},
        {9, 10},
        {1, 5},
        {6, 10},
        {5, 9},
        {2, 6},
        {1, 5},
        {6, 10},
        {0, 4},
        {7, 11},
        {3, 7},
        {4, 8},
        {0, 4},
        {7, 11},
        {1, 4},
        {7, 10},
        {3, 8},
        {2, 3},
        {8, 9},
        {2, 4},
        {7, 9},
        {3, 5},
        {6, 8},
        {3, 4},
        {5, 6},
        {7, 8},
      ]
    )

  # ditto
  NETWORK_13 =
    create(
      [
        {1, 7},
        {9, 11},
        {3, 4},
        {5, 8},
        {0, 12},
        {2, 6},
        {0, 1},
        {2, 3},
        {4, 6},
        {8, 11},
        {7, 12},
        {5, 9},
        {0, 2},
        {3, 7},
        {10, 11},
        {1, 4},
        {6, 12},
        {7, 8},
        {11, 12},
        {4, 9},
        {6, 10},
        {3, 4},
        {5, 6},
        {8, 9},
        {10, 11},
        {1, 7},
        {2, 6},
        {9, 11},
        {1, 3},
        {4, 7},
        {8, 10},
        {0, 5},
        {2, 5},
        {6, 8},
        {9, 10},
        {1, 2},
        {3, 5},
        {7, 8},
        {4, 6},
        {2, 3},
        {4, 5},
        {6, 7},
        {8, 9},
        {3, 4},
        {5, 6},
      ]
    )

  # ditto
  NETWORK_14 =
    create(
      [
        {0, 1},
        {2, 3},
        {4, 5},
        {6, 7},
        {8, 9},
        {10, 11},
        {12, 13},
        {0, 2},
        {4, 6},
        {8, 10},
        {1, 3},
        {5, 7},
        {9, 11},
        {0, 4},
        {8, 12},
        {1, 5},
        {9, 13},
        {2, 6},
        {3, 7},
        {0, 8},
        {1, 9},
        {2, 10},
        {3, 11},
        {4, 12},
        {5, 13},
        {5, 10},
        {6, 9},
        {3, 12},
        {7, 11},
        {1, 2},
        {4, 8},
        {1, 4},
        {7, 13},
        {2, 8},
        {2, 4},
        {5, 6},
        {9, 10},
        {11, 13},
        {3, 8},
        {7, 12},
        {6, 8},
        {10, 12},
        {3, 5},
        {7, 9},
        {3, 4},
        {5, 6},
        {7, 8},
        {9, 10},
        {11, 12},
        {6, 7},
        {8, 9},
      ]
    )

  # ditto
  NETWORK_15 =
    create(
      [
        {0, 1},
        {2, 3},
        {4, 5},
        {6, 7},
        {8, 9},
        {10, 11},
        {12, 13},
        {0, 2},
        {4, 6},
        {8, 10},
        {12, 14},
        {1, 3},
        {5, 7},
        {9, 11},
        {0, 4},
        {8, 12},
        {1, 5},
        {9, 13},
        {2, 6},
        {10, 14},
        {3, 7},
        {0, 8},
        {1, 9},
        {2, 10},
        {3, 11},
        {4, 12},
        {5, 13},
        {6, 14},
        {5, 10},
        {6, 9},
        {3, 12},
        {13, 14},
        {7, 11},
        {1, 2},
        {4, 8},
        {1, 4},
        {7, 13},
        {2, 8},
        {11, 14},
        {2, 4},
        {5, 6},
        {9, 10},
        {11, 13},
        {3, 8},
        {7, 12},
        {6, 8},
        {10, 12},
        {3, 5},
        {7, 9},
        {3, 4},
        {5, 6},
        {7, 8},
        {9, 10},
        {11, 12},
        {6, 7},
        {8, 9},
      ]
    )

  # ditto
  NETWORK_16 =
    create(
      [
        {0, 1},
        {2, 3},
        {4, 5},
        {6, 7},
        {8, 9},
        {10, 11},
        {12, 13},
        {14, 15},
        {0, 2},
        {4, 6},
        {8, 10},
        {12, 14},
        {1, 3},
        {5, 7},
        {9, 11},
        {13, 15},
        {0, 4},
        {8, 12},
        {1, 5},
        {9, 13},
        {2, 6},
        {10, 14},
        {3, 7},
        {11, 15},
        {0, 8},
        {1, 9},
        {2, 10},
        {3, 11},
        {4, 12},
        {5, 13},
        {6, 14},
        {7, 15},
        {5, 10},
        {6, 9},
        {3, 12},
        {13, 14},
        {7, 11},
        {1, 2},
        {4, 8},
        {1, 4},
        {7, 13},
        {2, 8},
        {11, 14},
        {2, 4},
        {5, 6},
        {9, 10},
        {11, 13},
        {3, 8},
        {7, 12},
        {6, 8},
        {10, 12},
        {3, 5},
        {7, 9},
        {3, 4},
        {5, 6},
        {7, 8},
        {9, 10},
        {11, 12},
        {6, 7},
        {8, 9},
      ]
    )

  # A network from "New Bounds on Optimal Sorting Networks" by Thorsten Ehlers
  # and Mike Müller.
  #
  # This is from the top right of the ninth page.
  NETWORK_17 =
    create(
      [
        # Layer 1.
        {0, 10},
        {12, 16},
        {1, 2},
        {3, 14},
        {4, 6},
        {7, 9},
        {11, 15},
        {5, 13},
        # Layer 2.
        {0, 7},
        {9, 10},
        {14, 16},
        {1, 5},
        {6, 15},
        {2, 13},
        {3, 12},
        {4, 11},
        # Layer 3.
        {0, 4},
        {5, 12},
        {13, 16},
        {1, 3},
        {6, 9},
        {10, 15},
        {2, 14},
        {7, 11},
        # Layer 4.
        {0, 8},
        {9, 12},
        # Unnecessary: comparator(1, 16),
        {2, 6},
        {10, 13},
        {3, 4},
        {5, 7},
        {11, 14},
        # Layer 5.
        {1, 11},
        # Unnecessary: comparator(12, 14),
        {15, 16},
        {2, 5},
        {6, 7},
        {9, 10},
        {3, 13},
        {4, 8},
        # Layer 6.
        {0, 3},
        {4, 9},
        {12, 14},
        {1, 2},
        {5, 6},
        {7, 11},
        {13, 15},
        {8, 10},
        # Layer 7.
        # Unnecessary: comparator(0, 1),
        {2, 4},
        {6, 8},
        {10, 11},
        {12, 13},
        {14, 15},
        {3, 5},
        {7, 9},
        # Layer 8.
        {0, 3},
        {4, 5},
        {6, 7},
        {8, 9},
        {10, 12},
        # Unnecessary: comparator(14, 16),
        {1, 2},
        {11, 13},
        # Layer 9.
        # NOTE: The figure shows {3, 5, 6, 7} in place of comparator(4, 6), comparator(5, 7).
        {0, 1},
        {2, 3},
        {4, 6},
        {5, 7},
        {8, 10},
        {11, 14},
        {9, 12},
        {13, 15},
        # Layer 10.
        {1, 2},
        {3, 4},
        {5, 6},
        {7, 8},
        {9, 10},
        {11, 12},
        {13, 14},
        {15, 16},
      ]
    )

  # A network from "New Bounds on Optimal Sorting Networks" by Thorsten Ehlers
  # and Mike Müller.
  #
  # This is from the middle of the ninth page.
  NETWORK_20 =
    create(
      [
        {0, 1},
        {2, 3},
        {4, 5},
        {6, 7},
        {8, 9},
        {10, 11},
        {12, 13},
        {14, 15},
        {16, 17},
        {18, 19},
        {0, 2},
        {1, 3},
        {4, 6},
        {5, 7},
        {8, 10},
        {9, 11},
        {12, 14},
        {13, 15},
        {16, 18},
        {17, 19},
        {0, 4},
        {1, 5},
        {2, 6},
        {3, 7},
        {9, 10},
        {12, 16},
        {13, 17},
        {14, 18},
        {15, 19},
        {0, 12},
        {1, 13},
        {2, 14},
        {3, 15},
        {4, 16},
        {5, 17},
        {6, 18},
        {7, 19},
        {0, 17},
        {1, 2},
        {3, 8},
        {11, 16},
        {4, 14},
        {15, 18},
        {5, 10},
        {6, 9},
        {7, 13},
        {0, 19},
        {1, 18},
        {2, 3},
        {4, 12},
        {13, 17},
        {5, 11},
        {15, 16},
        {6, 7},
        {8, 9},
        {10, 14},
        {1, 2},
        {3, 6},
        {7, 10},
        {14, 15},
        {16, 18},
        {4, 19},
        {5, 12},
        {8, 11},
        {9, 13},
        {0, 1},
        {2, 5},
        {6, 12},
        {13, 16},
        {18, 19},
        {3, 4},
        {7, 8},
        {9, 14},
        {15, 17},
        {10, 11},
        {1, 3},
        {4, 7},
        {8, 10},
        {11, 15},
        {16, 17},
        {2, 18},
        {5, 6},
        {9, 12},
        {13, 14},
        {0, 1},
        {2, 3},
        {4, 5},
        {6, 7},
        {8, 9},
        {10, 12},
        {14, 15},
        {16, 18},
        {11, 13},
        {17, 19},
        {3, 4},
        {5, 6},
        {7, 8},
        {9, 10},
        {11, 12},
        {13, 14},
        {15, 16},
        {17, 18},
      ]
    )

  # A width limited version of NETWORK_20.
  NETWORK_18 = with_limited_width(NETWORK_20, 18)

  # A width limited version of NETWORK_20.
  NETWORK_19 = with_limited_width(NETWORK_20, 19)

  # A network from "Merging almost sorted sequences yields a 24-sorter"
  # by Thorsten Ehlers.
  NETWORK_24 =
    create(
      [
        # Layer 1.
        {0, 1},
        {2, 3},
        {4, 5},
        {6, 7},
        {8, 9},
        {10, 11},
        {12, 13},
        {14, 15},
        {16, 17},
        {18, 19},
        {20, 21},
        {22, 23},
        # Layer 2.
        {0, 2},
        {1, 3},
        {4, 6},
        {5, 7},
        {8, 10},
        {9, 11},
        {12, 14},
        {13, 15},
        {16, 18},
        {17, 19},
        {20, 22},
        {21, 23},
        # Layer 3.
        {0, 4},
        {1, 5},
        {2, 8},
        {3, 9},
        {6, 10},
        {7, 11},
        {12, 16},
        {13, 17},
        {14, 20},
        {15, 21},
        {18, 22},
        {19, 23},
        # Layer 4.
        {0, 2},
        {1, 3},
        {4, 6},
        {5, 7},
        {8, 10},
        {9, 11},
        {12, 14},
        {13, 15},
        {16, 18},
        {17, 19},
        {20, 22},
        {21, 23},
        # Layer 5.
        {0, 12},
        {2, 4},
        {3, 5},
        {6, 8},
        {7, 9},
        {11, 23},
        {14, 16},
        {15, 17},
        {18, 20},
        {19, 21},
        # Layer 6.
        {1, 13},
        {2, 14},
        {3, 15},
        {6, 16},
        {7, 17},
        {4, 18},
        {5, 19},
        {8, 20},
        {9, 21},
        {10, 22},
        # Layer 7.
        {1, 12},
        {3, 14},
        {5, 18},
        {4, 6},
        {7, 16},
        {8, 13},
        {9, 20},
        {10, 15},
        {11, 22},
        {17, 19},
        # Layer 8.
        {1, 4},
        {3, 6},
        {5, 7},
        {8, 12},
        {9, 13},
        {10, 14},
        {11, 15},
        {16, 18},
        {17, 20},
        {19, 22},
        # Layer 9.
        {3, 8},
        {5, 12},
        {6, 10},
        {7, 14},
        {9, 16},
        {11, 18},
        {13, 17},
        {15, 19},
        {21, 22},
        # Layer 10.
        {2, 3},
        {4, 5},
        {6, 8},
        {7, 9},
        {10, 12},
        {11, 16},
        {13, 14},
        {15, 17},
        {18, 20},
        {19, 21},
        # Layer 11.
        {1, 2},
        {4, 6},
        {5, 8},
        {7, 10},
        {9, 12},
        {11, 13},
        {14, 16},
        {15, 18},
        {17, 20},
        # Layer 12.
        {3, 4},
        {5, 6},
        {7, 8},
        {9, 10},
        {11, 12},
        {13, 14},
        {15, 16},
        {17, 18},
        {19, 20},
      ]
    )

  # A width limited version of NETWORK_24.
  NETWORK_21 = with_limited_width(NETWORK_24, 21)

  # A width limited version of NETWORK_24.
  NETWORK_22 = with_limited_width(NETWORK_24, 22)

  # A width limited version of NETWORK_24.
  NETWORK_23 = with_limited_width(NETWORK_24, 23)
end