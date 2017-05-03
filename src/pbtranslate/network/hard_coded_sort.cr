require "../scheme"

# A collection of good networks of fixed widths.
module PBTranslate::Network::HardCodedSort
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

  private macro comparator(a, b)
    {Distance.new({{a}}), Distance.new({{b}})}
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
        comparator(0, 1),
      ]
    )

  # ditto
  NETWORK_03 =
    create(
      [
        comparator(1, 2),
        comparator(0, 2),
        comparator(0, 1),
      ]
    )

  # ditto
  NETWORK_04 =
    create(
      [
        comparator(0, 1),
        comparator(2, 3),
        comparator(0, 2),
        comparator(1, 3),
        comparator(1, 2),
      ]
    )

  # A network generated with "sortnetgen 5 --measure=count --level-factor=1.1".
  NETWORK_05 =
    create(
      [
        comparator(0, 1),
        comparator(2, 3),
        comparator(0, 2),
        comparator(1, 4),
        comparator(1, 2),
        comparator(3, 4),
        comparator(0, 1),
        comparator(2, 3),
        comparator(1, 2),
      ]
    )

  # A network generated using the Bose-Nelson algorithm on the website
  # http://pages.ripco.net/~jgamble/nw.html
  NETWORK_06 =
    create(
      [
        comparator(1, 2),
        comparator(0, 2),
        comparator(0, 1),
        comparator(4, 5),
        comparator(3, 5),
        comparator(3, 4),
        comparator(0, 3),
        comparator(1, 4),
        comparator(2, 5),
        comparator(2, 4),
        comparator(1, 3),
        comparator(2, 3),
      ]
    )

  # ditto
  NETWORK_07 =
    create(
      [
        comparator(1, 2),
        comparator(0, 2),
        comparator(0, 1),
        comparator(3, 4),
        comparator(5, 6),
        comparator(3, 5),
        comparator(4, 6),
        comparator(4, 5),
        comparator(0, 4),
        comparator(0, 3),
        comparator(1, 5),
        comparator(2, 6),
        comparator(2, 5),
        comparator(1, 3),
        comparator(2, 4),
        comparator(2, 3),
      ]
    )

  # ditto
  NETWORK_08 =
    create(
      [
        comparator(0, 1),
        comparator(2, 3),
        comparator(0, 2),
        comparator(1, 3),
        comparator(1, 2),
        comparator(4, 5),
        comparator(6, 7),
        comparator(4, 6),
        comparator(5, 7),
        comparator(5, 6),
        comparator(0, 4),
        comparator(1, 5),
        comparator(1, 4),
        comparator(2, 6),
        comparator(3, 7),
        comparator(3, 6),
        comparator(2, 4),
        comparator(3, 5),
        comparator(3, 4),
      ]
    )

  # A network generated using the "Best" option on the website
  # http://pages.ripco.net/~jgamble/nw.html
  NETWORK_09 =
    create(
      [
        comparator(0, 1),
        comparator(3, 4),
        comparator(6, 7),
        comparator(1, 2),
        comparator(4, 5),
        comparator(7, 8),
        comparator(0, 1),
        comparator(3, 4),
        comparator(6, 7),
        comparator(0, 3),
        comparator(3, 6),
        comparator(0, 3),
        comparator(1, 4),
        comparator(4, 7),
        comparator(1, 4),
        comparator(2, 5),
        comparator(5, 8),
        comparator(2, 5),
        comparator(1, 3),
        comparator(5, 7),
        comparator(2, 6),
        comparator(4, 6),
        comparator(2, 4),
        comparator(2, 3),
        comparator(5, 6),
      ]
    )

  # ditto
  NETWORK_10 =
    create(
      [
        comparator(4, 9),
        comparator(3, 8),
        comparator(2, 7),
        comparator(1, 6),
        comparator(0, 5),
        comparator(1, 4),
        comparator(6, 9),
        comparator(0, 3),
        comparator(5, 8),
        comparator(0, 2),
        comparator(3, 6),
        comparator(7, 9),
        comparator(0, 1),
        comparator(2, 4),
        comparator(5, 7),
        comparator(8, 9),
        comparator(1, 2),
        comparator(4, 6),
        comparator(7, 8),
        comparator(3, 5),
        comparator(2, 5),
        comparator(6, 8),
        comparator(1, 3),
        comparator(4, 7),
        comparator(2, 3),
        comparator(6, 7),
        comparator(3, 4),
        comparator(5, 6),
        comparator(4, 5),
      ]
    )

  # ditto
  NETWORK_11 =
    create(
      [
        comparator(0, 1),
        comparator(2, 3),
        comparator(4, 5),
        comparator(6, 7),
        comparator(8, 9),
        comparator(1, 3),
        comparator(5, 7),
        comparator(0, 2),
        comparator(4, 6),
        comparator(8, 10),
        comparator(1, 2),
        comparator(5, 6),
        comparator(9, 10),
        comparator(1, 5),
        comparator(6, 10),
        comparator(5, 9),
        comparator(2, 6),
        comparator(1, 5),
        comparator(6, 10),
        comparator(0, 4),
        comparator(3, 7),
        comparator(4, 8),
        comparator(0, 4),
        comparator(1, 4),
        comparator(7, 10),
        comparator(3, 8),
        comparator(2, 3),
        comparator(8, 9),
        comparator(2, 4),
        comparator(7, 9),
        comparator(3, 5),
        comparator(6, 8),
        comparator(3, 4),
        comparator(5, 6),
        comparator(7, 8),
      ]
    )

  # ditto
  NETWORK_12 =
    create(
      [
        comparator(0, 1),
        comparator(2, 3),
        comparator(4, 5),
        comparator(6, 7),
        comparator(8, 9),
        comparator(10, 11),
        comparator(1, 3),
        comparator(5, 7),
        comparator(9, 11),
        comparator(0, 2),
        comparator(4, 6),
        comparator(8, 10),
        comparator(1, 2),
        comparator(5, 6),
        comparator(9, 10),
        comparator(1, 5),
        comparator(6, 10),
        comparator(5, 9),
        comparator(2, 6),
        comparator(1, 5),
        comparator(6, 10),
        comparator(0, 4),
        comparator(7, 11),
        comparator(3, 7),
        comparator(4, 8),
        comparator(0, 4),
        comparator(7, 11),
        comparator(1, 4),
        comparator(7, 10),
        comparator(3, 8),
        comparator(2, 3),
        comparator(8, 9),
        comparator(2, 4),
        comparator(7, 9),
        comparator(3, 5),
        comparator(6, 8),
        comparator(3, 4),
        comparator(5, 6),
        comparator(7, 8),
      ]
    )

  # ditto
  NETWORK_13 =
    create(
      [
        comparator(1, 7),
        comparator(9, 11),
        comparator(3, 4),
        comparator(5, 8),
        comparator(0, 12),
        comparator(2, 6),
        comparator(0, 1),
        comparator(2, 3),
        comparator(4, 6),
        comparator(8, 11),
        comparator(7, 12),
        comparator(5, 9),
        comparator(0, 2),
        comparator(3, 7),
        comparator(10, 11),
        comparator(1, 4),
        comparator(6, 12),
        comparator(7, 8),
        comparator(11, 12),
        comparator(4, 9),
        comparator(6, 10),
        comparator(3, 4),
        comparator(5, 6),
        comparator(8, 9),
        comparator(10, 11),
        comparator(1, 7),
        comparator(2, 6),
        comparator(9, 11),
        comparator(1, 3),
        comparator(4, 7),
        comparator(8, 10),
        comparator(0, 5),
        comparator(2, 5),
        comparator(6, 8),
        comparator(9, 10),
        comparator(1, 2),
        comparator(3, 5),
        comparator(7, 8),
        comparator(4, 6),
        comparator(2, 3),
        comparator(4, 5),
        comparator(6, 7),
        comparator(8, 9),
        comparator(3, 4),
        comparator(5, 6),
      ]
    )

  # ditto
  NETWORK_14 =
    create(
      [
        comparator(0, 1),
        comparator(2, 3),
        comparator(4, 5),
        comparator(6, 7),
        comparator(8, 9),
        comparator(10, 11),
        comparator(12, 13),
        comparator(0, 2),
        comparator(4, 6),
        comparator(8, 10),
        comparator(1, 3),
        comparator(5, 7),
        comparator(9, 11),
        comparator(0, 4),
        comparator(8, 12),
        comparator(1, 5),
        comparator(9, 13),
        comparator(2, 6),
        comparator(3, 7),
        comparator(0, 8),
        comparator(1, 9),
        comparator(2, 10),
        comparator(3, 11),
        comparator(4, 12),
        comparator(5, 13),
        comparator(5, 10),
        comparator(6, 9),
        comparator(3, 12),
        comparator(7, 11),
        comparator(1, 2),
        comparator(4, 8),
        comparator(1, 4),
        comparator(7, 13),
        comparator(2, 8),
        comparator(2, 4),
        comparator(5, 6),
        comparator(9, 10),
        comparator(11, 13),
        comparator(3, 8),
        comparator(7, 12),
        comparator(6, 8),
        comparator(10, 12),
        comparator(3, 5),
        comparator(7, 9),
        comparator(3, 4),
        comparator(5, 6),
        comparator(7, 8),
        comparator(9, 10),
        comparator(11, 12),
        comparator(6, 7),
        comparator(8, 9),
      ]
    )

  # ditto
  NETWORK_15 =
    create(
      [
        comparator(0, 1),
        comparator(2, 3),
        comparator(4, 5),
        comparator(6, 7),
        comparator(8, 9),
        comparator(10, 11),
        comparator(12, 13),
        comparator(0, 2),
        comparator(4, 6),
        comparator(8, 10),
        comparator(12, 14),
        comparator(1, 3),
        comparator(5, 7),
        comparator(9, 11),
        comparator(0, 4),
        comparator(8, 12),
        comparator(1, 5),
        comparator(9, 13),
        comparator(2, 6),
        comparator(10, 14),
        comparator(3, 7),
        comparator(0, 8),
        comparator(1, 9),
        comparator(2, 10),
        comparator(3, 11),
        comparator(4, 12),
        comparator(5, 13),
        comparator(6, 14),
        comparator(5, 10),
        comparator(6, 9),
        comparator(3, 12),
        comparator(13, 14),
        comparator(7, 11),
        comparator(1, 2),
        comparator(4, 8),
        comparator(1, 4),
        comparator(7, 13),
        comparator(2, 8),
        comparator(11, 14),
        comparator(2, 4),
        comparator(5, 6),
        comparator(9, 10),
        comparator(11, 13),
        comparator(3, 8),
        comparator(7, 12),
        comparator(6, 8),
        comparator(10, 12),
        comparator(3, 5),
        comparator(7, 9),
        comparator(3, 4),
        comparator(5, 6),
        comparator(7, 8),
        comparator(9, 10),
        comparator(11, 12),
        comparator(6, 7),
        comparator(8, 9),
      ]
    )

  # ditto
  NETWORK_16 =
    create(
      [
        comparator(0, 1),
        comparator(2, 3),
        comparator(4, 5),
        comparator(6, 7),
        comparator(8, 9),
        comparator(10, 11),
        comparator(12, 13),
        comparator(14, 15),
        comparator(0, 2),
        comparator(4, 6),
        comparator(8, 10),
        comparator(12, 14),
        comparator(1, 3),
        comparator(5, 7),
        comparator(9, 11),
        comparator(13, 15),
        comparator(0, 4),
        comparator(8, 12),
        comparator(1, 5),
        comparator(9, 13),
        comparator(2, 6),
        comparator(10, 14),
        comparator(3, 7),
        comparator(11, 15),
        comparator(0, 8),
        comparator(1, 9),
        comparator(2, 10),
        comparator(3, 11),
        comparator(4, 12),
        comparator(5, 13),
        comparator(6, 14),
        comparator(7, 15),
        comparator(5, 10),
        comparator(6, 9),
        comparator(3, 12),
        comparator(13, 14),
        comparator(7, 11),
        comparator(1, 2),
        comparator(4, 8),
        comparator(1, 4),
        comparator(7, 13),
        comparator(2, 8),
        comparator(11, 14),
        comparator(2, 4),
        comparator(5, 6),
        comparator(9, 10),
        comparator(11, 13),
        comparator(3, 8),
        comparator(7, 12),
        comparator(6, 8),
        comparator(10, 12),
        comparator(3, 5),
        comparator(7, 9),
        comparator(3, 4),
        comparator(5, 6),
        comparator(7, 8),
        comparator(9, 10),
        comparator(11, 12),
        comparator(6, 7),
        comparator(8, 9),
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
        comparator(0, 10),
        comparator(12, 16),
        comparator(1, 2),
        comparator(3, 14),
        comparator(4, 6),
        comparator(7, 9),
        comparator(11, 15),
        comparator(5, 13),
        # Layer 2.
        comparator(0, 7),
        comparator(9, 10),
        comparator(14, 16),
        comparator(1, 5),
        comparator(6, 15),
        comparator(2, 13),
        comparator(3, 12),
        comparator(4, 11),
        # Layer 3.
        comparator(0, 4),
        comparator(5, 12),
        comparator(13, 16),
        comparator(1, 3),
        comparator(6, 9),
        comparator(10, 15),
        comparator(2, 14),
        comparator(7, 11),
        # Layer 4.
        comparator(0, 8),
        comparator(9, 12),
        # Unnecessary: comparator(1, 16),
        comparator(2, 6),
        comparator(10, 13),
        comparator(3, 4),
        comparator(5, 7),
        comparator(11, 14),
        # Layer 5.
        comparator(1, 11),
        # Unnecessary: comparator(12, 14),
        comparator(15, 16),
        comparator(2, 5),
        comparator(6, 7),
        comparator(9, 10),
        comparator(3, 13),
        comparator(4, 8),
        # Layer 6.
        comparator(0, 3),
        comparator(4, 9),
        comparator(12, 14),
        comparator(1, 2),
        comparator(5, 6),
        comparator(7, 11),
        comparator(13, 15),
        comparator(8, 10),
        # Layer 7.
        # Unnecessary: comparator(0, 1),
        comparator(2, 4),
        comparator(6, 8),
        comparator(10, 11),
        comparator(12, 13),
        comparator(14, 15),
        comparator(3, 5),
        comparator(7, 9),
        # Layer 8.
        comparator(0, 3),
        comparator(4, 5),
        comparator(6, 7),
        comparator(8, 9),
        comparator(10, 12),
        # Unnecessary: comparator(14, 16),
        comparator(1, 2),
        comparator(11, 13),
        # Layer 9.
        # NOTE: The figure shows {3, 5, 6, 7} in place of comparator(4, 6), comparator(5, 7).
        comparator(0, 1),
        comparator(2, 3),
        comparator(4, 6),
        comparator(5, 7),
        comparator(8, 10),
        comparator(11, 14),
        comparator(9, 12),
        comparator(13, 15),
        # Layer 10.
        comparator(1, 2),
        comparator(3, 4),
        comparator(5, 6),
        comparator(7, 8),
        comparator(9, 10),
        comparator(11, 12),
        comparator(13, 14),
        comparator(15, 16),
      ]
    )

  # A network from "New Bounds on Optimal Sorting Networks" by Thorsten Ehlers
  # and Mike Müller.
  #
  # This is from the middle of the ninth page.
  NETWORK_20 =
    create(
      [
        comparator(0, 1),
        comparator(2, 3),
        comparator(4, 5),
        comparator(6, 7),
        comparator(8, 9),
        comparator(10, 11),
        comparator(12, 13),
        comparator(14, 15),
        comparator(16, 17),
        comparator(18, 19),
        comparator(0, 2),
        comparator(1, 3),
        comparator(4, 6),
        comparator(5, 7),
        comparator(8, 10),
        comparator(9, 11),
        comparator(12, 14),
        comparator(13, 15),
        comparator(16, 18),
        comparator(17, 19),
        comparator(0, 4),
        comparator(1, 5),
        comparator(2, 6),
        comparator(3, 7),
        comparator(9, 10),
        comparator(12, 16),
        comparator(13, 17),
        comparator(14, 18),
        comparator(15, 19),
        comparator(0, 12),
        comparator(1, 13),
        comparator(2, 14),
        comparator(3, 15),
        comparator(4, 16),
        comparator(5, 17),
        comparator(6, 18),
        comparator(7, 19),
        comparator(0, 17),
        comparator(1, 2),
        comparator(3, 8),
        comparator(11, 16),
        comparator(4, 14),
        comparator(15, 18),
        comparator(5, 10),
        comparator(6, 9),
        comparator(7, 13),
        comparator(0, 19),
        comparator(1, 18),
        comparator(2, 3),
        comparator(4, 12),
        comparator(13, 17),
        comparator(5, 11),
        comparator(15, 16),
        comparator(6, 7),
        comparator(8, 9),
        comparator(10, 14),
        comparator(1, 2),
        comparator(3, 6),
        comparator(7, 10),
        comparator(14, 15),
        comparator(16, 18),
        comparator(4, 19),
        comparator(5, 12),
        comparator(8, 11),
        comparator(9, 13),
        comparator(0, 1),
        comparator(2, 5),
        comparator(6, 12),
        comparator(13, 16),
        comparator(18, 19),
        comparator(3, 4),
        comparator(7, 8),
        comparator(9, 14),
        comparator(15, 17),
        comparator(10, 11),
        comparator(1, 3),
        comparator(4, 7),
        comparator(8, 10),
        comparator(11, 15),
        comparator(16, 17),
        comparator(2, 18),
        comparator(5, 6),
        comparator(9, 12),
        comparator(13, 14),
        comparator(0, 1),
        comparator(2, 3),
        comparator(4, 5),
        comparator(6, 7),
        comparator(8, 9),
        comparator(10, 12),
        comparator(14, 15),
        comparator(16, 18),
        comparator(11, 13),
        comparator(17, 19),
        comparator(3, 4),
        comparator(5, 6),
        comparator(7, 8),
        comparator(9, 10),
        comparator(11, 12),
        comparator(13, 14),
        comparator(15, 16),
        comparator(17, 18),
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
        comparator(0, 1),
        comparator(2, 3),
        comparator(4, 5),
        comparator(6, 7),
        comparator(8, 9),
        comparator(10, 11),
        comparator(12, 13),
        comparator(14, 15),
        comparator(16, 17),
        comparator(18, 19),
        comparator(20, 21),
        comparator(22, 23),
        # Layer 2.
        comparator(0, 2),
        comparator(1, 3),
        comparator(4, 6),
        comparator(5, 7),
        comparator(8, 10),
        comparator(9, 11),
        comparator(12, 14),
        comparator(13, 15),
        comparator(16, 18),
        comparator(17, 19),
        comparator(20, 22),
        comparator(21, 23),
        # Layer 3.
        comparator(0, 4),
        comparator(1, 5),
        comparator(2, 8),
        comparator(3, 9),
        comparator(6, 10),
        comparator(7, 11),
        comparator(12, 16),
        comparator(13, 17),
        comparator(14, 20),
        comparator(15, 21),
        comparator(18, 22),
        comparator(19, 23),
        # Layer 4.
        comparator(0, 2),
        comparator(1, 3),
        comparator(4, 6),
        comparator(5, 7),
        comparator(8, 10),
        comparator(9, 11),
        comparator(12, 14),
        comparator(13, 15),
        comparator(16, 18),
        comparator(17, 19),
        comparator(20, 22),
        comparator(21, 23),
        # Layer 5.
        comparator(0, 12),
        comparator(2, 4),
        comparator(3, 5),
        comparator(6, 8),
        comparator(7, 9),
        comparator(11, 23),
        comparator(14, 16),
        comparator(15, 17),
        comparator(18, 20),
        comparator(19, 21),
        # Layer 6.
        comparator(1, 13),
        comparator(2, 14),
        comparator(3, 15),
        comparator(6, 16),
        comparator(7, 17),
        comparator(4, 18),
        comparator(5, 19),
        comparator(8, 20),
        comparator(9, 21),
        comparator(10, 22),
        # Layer 7.
        comparator(1, 12),
        comparator(3, 14),
        comparator(5, 18),
        comparator(4, 6),
        comparator(7, 16),
        comparator(8, 13),
        comparator(9, 20),
        comparator(10, 15),
        comparator(11, 22),
        comparator(17, 19),
        # Layer 8.
        comparator(1, 4),
        comparator(3, 6),
        comparator(5, 7),
        comparator(8, 12),
        comparator(9, 13),
        comparator(10, 14),
        comparator(11, 15),
        comparator(16, 18),
        comparator(17, 20),
        comparator(19, 22),
        # Layer 9.
        comparator(3, 8),
        comparator(5, 12),
        comparator(6, 10),
        comparator(7, 14),
        comparator(9, 16),
        comparator(11, 18),
        comparator(13, 17),
        comparator(15, 19),
        comparator(21, 22),
        # Layer 10.
        comparator(2, 3),
        comparator(4, 5),
        comparator(6, 8),
        comparator(7, 9),
        comparator(10, 12),
        comparator(11, 16),
        comparator(13, 14),
        comparator(15, 17),
        comparator(18, 20),
        comparator(19, 21),
        # Layer 11.
        comparator(1, 2),
        comparator(4, 6),
        comparator(5, 8),
        comparator(7, 10),
        comparator(9, 12),
        comparator(11, 13),
        comparator(14, 16),
        comparator(15, 18),
        comparator(17, 20),
        # Layer 12.
        comparator(3, 4),
        comparator(5, 6),
        comparator(7, 8),
        comparator(9, 10),
        comparator(11, 12),
        comparator(13, 14),
        comparator(15, 16),
        comparator(17, 18),
        comparator(19, 20),
      ]
    )

  # A width limited version of NETWORK_24.
  NETWORK_21 = with_limited_width(NETWORK_24, 21)

  # A width limited version of NETWORK_24.
  NETWORK_22 = with_limited_width(NETWORK_24, 22)

  # A width limited version of NETWORK_24.
  NETWORK_23 = with_limited_width(NETWORK_24, 23)
end
