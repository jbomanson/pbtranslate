require "../network"
require "../number_types"

module PBTranslate::Network
  # Creates an empty network with no gates.
  #
  # This is intended for use as an identity element in composite networks, such
  # as a base case in recursively constructed networks.
  # The returned network does not have well defined gate options when used
  # alone.
  def self.empty : Network
    Empty.new
  end
end

include PBTranslate

private struct Empty
  include Network

  {% for message_and_type in [
                               {:network_depth, Distance},
                               {:network_width, Distance},
                               {:network_write_count, Area},
                             ] %}
    # Returns zero.
    def {{message_and_type[0].id}} : {{message_and_type[1]}}
      {{message_and_type[1]}}.new(0)
    end
  {% end %}

  # Does nothing.
  def host_reduce(visitor, memo)
    memo
  end
end
