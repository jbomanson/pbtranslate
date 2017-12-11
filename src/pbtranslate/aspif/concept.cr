# A module containing a collection of structs, enums and modules that capture
# the concepts expressed in ASPIF.
#
# For convenience, this module is included in the ASPIF module.
module PBTranslate::ASPIF::Concept
  module ::PBTranslate::ASPIF
    include Concept
  end

  struct Literal(T)
    def self.new(value : Int, reporter)
      if value == 0
        reporter.problem("zero literal")
        nil
      else
        new(value)
      end
    end

    getter value

    def initialize(@value : T)
    end

    def number
      value.abs
    end

    def positive?
      value > 0
    end

    def negative?
      value < 0
    end
  end

  # Enums.

  enum Statement
    Rule       = 1
    Minimize
    Projection
    Output
    External
    Assumption
    Heuristic
    Edge
    Theory
    Comment
  end

  enum Head
    Disjunction
    Choice
  end

  enum Body
    Normal
    Weight
  end

  enum External
    Free
    True
    False
    Release
  end

  enum Heuristic
    Level
    Sign
    Factor
    Init
    True
  end

  enum TheoryStatement
    TermNumeric  = 0
    TermString   = 1
    TermFunction = 2
    AtomElement  = 4
    Atom5        = 5
    Atom6        = 6
  end

  # Modules.

  abstract struct Element
  end

  macro element(name, *properties)
    struct {{name.id}} < Element
      def to_s(io)
        {% for property, index in properties %}
          {% if index != 0 %}
            io << ' '
          {% end %}
          io << {{
                  (property.is_a? Assign) ? property.target.var : property.var
                }}
        {% end %}
      end
    end

    record {{name}}, {{*properties}} do
      {{yield}}
    end
  end

  macro element_with_bytesize(name, prop)
    element {{name}}, bytesize : Int32, {{prop}} do
      def self.new(*args)
        new(args.first.bytesize, *args)
      end

      {{yield}}
    end
  end

  module Constant
  end

  macro constant(name, s)
    module {{name}}
      extend Constant

      def self.to_s(io)
        io << {{s}}
      end
    end
  end

  module Marker
  end

  macro marker(name)
    module {{name}}
      extend Marker
    end
  end

  element Tag, value : String
  element_with_bytesize OutputString, value : String
  element Edge(T), u : T, v : T
  element Comment, value : String
  element IntegerListStart, size : Int32
  element LiteralListStart, size : Int32
  element WeightedLiteralListStart, size : Int32
  element TheoryTermNumeric, value : Int32
  element_with_bytesize TheoryTermString, value : String
  element TheoryTermFunction, value : Int32
  element TheoryAtomOperator, value : Int32

  constant Header, "asp"
  constant Newline, '\n'
  constant EndOfLogicProgram, '0'

  marker MinimizeStatement
  marker ProjectionStatement
  marker AssumptionStatement
  marker TheoryAtomElement
  marker TheoryAtom5
  marker TheoryAtom6
end
