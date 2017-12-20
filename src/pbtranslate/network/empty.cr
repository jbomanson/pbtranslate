require "../network"
require "../number_types"

# An empty network with no gates.
#
# Intended for use as an identity element in composite networks, such as a base
# case in recursively constructed networks.
# Does not have well defined gate options when used alone.
struct PBTranslate::Network::Empty
  include Network

  # An instance of this network.
  INSTANCE = new

  # :nodoc:
  def initialize
  end

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
