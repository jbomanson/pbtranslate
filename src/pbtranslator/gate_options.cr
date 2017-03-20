struct NamedTuple
  def pbtranslator_gate_options_to_s(io)
    io << "{"
    delim = ""
    {% for key, value in T %}
      {% unless value == Nil %}
        io << delim
        io << {{key.stringify}}
        {% if value.union? %}
          io << '?'
        {% end %}
        delim = ", "
      {% end %}
    {% end %}
    io << "}"
  end

  def pbtranslator_gate_options_take_interesting
    {% begin %}
      NamedTuple.new(
        {% for key, value in T %}
          {% unless value == Nil %}
            {{key.id}}: true.as({{value}}),
          {% end %}
        {% end %}
      )
    {% end %}
  end
end

struct PBTranslator::GateOptions(O)
  module Module
    macro delegate_and_declare_gate_options(other, *args)
      def gate_options(**extra)
        {{other.id}}.gate_options(**extra, {{args.map { |key| "#{key}: true" }.join(", ").id}}) { |o| yield o }
      end

      def gate_options(**extra)
        gate_options(**extra, &.itself)
      end
    end

    macro declare_gate_options(*args)
      def gate_options(**extra)
        yield ::PBTranslator::GateOptions.new(**extra, {{args.map { |key| "#{key}: true" }.join(", ").id}})
      end

      def gate_options(**extra)
        gate_options(**extra, &.itself)
      end
    end
  end

  alias Element = Bool | Nil

  getter named_tuple : O

  def self.complete_exact(
    *,
    depth : Element = nil,
    output_cone : Element = nil)
    {depth: depth, output_cone: output_cone}
  end

  def self.complete_relaxed(
    *,
    depth : Element = nil.as(Element),
    output_cone : Element = nil.as(Element))
    {depth: depth, output_cone: output_cone}
  end

  def self.new(**options)
    new(NamedTuple.new, options)
  end

  protected def self.new(elements, options)
    ensure_all_true(*options.values)
    c = complete_exact(**elements, **options)
    wrap(**c)
  end

  protected def self.wrap(**options)
    new(:disambiguation, **options)
  end

  private def self.ensure_all_true(*args : Bool)
    unless args.all?
      raise "Expected only true values, got #{args}"
    end
  end

  private def self.ensure_all_true
  end

  protected def initialize(disambiguation, **options : **O)
    # TODO: Reconstruct the following from O.
    @named_tuple = options
  end

  def or(other : GateOptions)
    GateOptions.wrap(**(true ? self : other).named_tuple)
  end

  def with(**options)
    GateOptions.new(interesting_named_tuple, options)
  end

  def interesting_named_tuple
    named_tuple.pbtranslator_gate_options_take_interesting
  end

  def to_s(io)
    @named_tuple.pbtranslator_gate_options_to_s(io)
  end
  
  def inspect(io)
    to_s(io)
  end

  def restrict(**options : Element)
    expected = typeof(GateOptions.complete_relaxed(**options))
    GateOptions.restrict_helper(expected, **named_tuple)
  end

  protected def self.restrict_helper(expected : P.class, **options : **P) forall P
  end
end
