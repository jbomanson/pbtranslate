module PBTranslate::Network
  # Converts this network to one with its contents in reverse order.
  #
  # To work nicely, this network must support iteration in both ways.
  #
  # These calls are mutually equivalent:
  # * `host(visitor.going(way))`.
  # * `to_network_reverse.host(visitor.going(way.reverse))`.
  def to_network_reverse : Network
    ToNetworkReverse.new(self)
  end
end

private struct ToNetworkReverse(N)
  include PBTranslate::Network

  delegate network_depth, network_read_count, network_width, network_write_count, to: @network

  def initialize(@network : N)
  end

  def host_reduce(visitor, memo)
    @network.host_reduce(visitor.going(visitor.way.reverse), memo)
  end
end
