require "./reader"

# An object to rename atom numbers in a program written in ASPIF.
#
# The numbers are produced by renaming with `Util::IdBroker`.
#
# ### Example
#
#     id_broker = Util::IdBroker.new
#     id_broker.fresh_id # => 0 : Int32
#
#     s =
#       <<-EOF
#       asp 1 0 0 one two three
#       2 100 3 100 100 200 200 300 300
#       1 0 1 1 0 0
#       1 0 1 2 0 0
#       1 0 1 3 0 0
#       4 7 task(1) 1 1
#       4 7 task(2) 1 2
#       4 7 task(3) 1 3
#       0
#
#       EOF
#
#     r =
#       String.build do |builder|
#         aspif_broker = ASPIF::Broker.new(s, builder, id_broker)
#         aspif_broker.parse
#       end
#
#     puts r
#     # asp 1 0 0 one two three
#     # 2 100 3 356 100 456 200 556 300
#     # 1 0 1 257 0 0
#     # 1 0 1 258 0 0
#     # 1 0 1 259 0 0
#     # 4 7 task(1) 1 257
#     # 4 7 task(2) 1 258
#     # 4 7 task(3) 1 259
#     # 0
#
#     id_broker.fresh_id # => 1 : Int32
class PBTranslator::ASPIF::Broker < PBTranslator::ASPIF::Reader
  delegate fresh_id, to: @id_broker

  # Creates a new Broker that reads from `source`, writes to `sink_io` and
  # renames with `id_broker`.
  #
  # The source is interpreted as by `ASPIF::Reader`.
  def initialize(
                 source,
                 @sink_io : IO,
                 @id_broker : Util::IdBroker = Util::IdBroker.new)
    super(source)
    @start_of_line = true
  end

  protected def rename(literal_value : Int)
    sign = literal_value < 0 ? -1 : 1
    atom = literal_value.abs
    Literal.new(@id_broker.rename(atom).operate &.*(sign))
  end

  protected def token(e : Enum)
    token(e.value)
  end

  protected def token(m : Marker)
    true
  end

  protected def token(l : Literal(Util::BrokeredId(T))) forall T
    check_int(T)
    token(l.value.brokered_id)
  end

  protected def token(b : Util::BrokeredId)
    -"This method should not be called with Util::BrokeredId"
  end

  protected def token(l : Literal(T)) forall T
    check_int(T)
    token(rename(l.value))
  end

  private def check_int(i : Int.class)
  end

  protected def token(s : String)
    token s.bytesize
    simple_token s
  end

  protected def token(w)
    simple_token w
  end

  protected def simple_token(w)
    @sink_io << ' ' unless @start_of_line
    @sink_io << w
    @start_of_line = false
    true
  end

  #
  #     Output methods corresponding to visit methods
  #

  def output(c : Newline.class) : Bool
    @sink_io << '\n'
    @start_of_line = true
    true
  end

  def output(*args) : Bool
    args.each do |arg|
      token arg
    end
    true
  end

  def output(*args) : Bool
    output(*args)
    yield
    true
  end

  #
  #     Visit methods called by Reader
  #

  # :nodoc:
  def visit(*args) : Bool
    output(*args)
  end

  # :nodoc:
  def visit(*args) : Bool
    output(*args) { yield }
  end
end
