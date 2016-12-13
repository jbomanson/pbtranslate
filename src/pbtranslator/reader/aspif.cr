require "./helper"

# TODO: Bump positions pointing to spaces in error messages.
# TODO: Decrement positions pointing after enums in error messages.

# This is based on the definition of the ASP Input Format (ASPIF)
# in Appendix A of
# "Theory Solving made easy with Clingo 5 (Extended Version ∗)".

module PBTranslator::Reader
  class ASPIF
    include Helper::Name

    EXISTING = MatchKind.new("missing", "partial")
    POSSIBLY_EMPTY = MatchKind.new("faulty", "partial")

    # This is used here in place of Tuple{T, T, T} due to a compiler error in
    # crystal 0.19.1.
    struct Version(T)
      getter major
      getter minor
      getter revision

      def initialize(@major : T, @minor : T, @revision : T)
      end
    end

    struct Literal(T)
      def self.new(value : Int, reporter)
        if value == 0
          reporter.problem("zero literal")
          nil
        else
          self.new(value)
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
      Rule = 1
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
      TermNumeric = 0
      TermString = 1
      TermFunction = 2
      AtomElement = 4
      Atom5 = 5
      Atom6 = 6
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

    #

    private delegate_helper_methods_to @helper

    delegate :problem, to: @helper

    def visit(c : Header.class, major : Int, minor : Int, revision : Int) : Bool
      !!yield
    end

    def visit(c : Newline.class) : Bool
      true
    end

    def visit(tag : Tag) : Bool
      true
    end

    def visit(c : EndOfLogicProgram.class) : Bool
      true
    end

    def visit(s : Statement) : Bool
      !!yield
    end

    def visit(h : Head) : Bool
      !!yield
    end

    def visit(b : Body) : Bool
      !!yield
    end

    def visit(b : Body, lower_bound : Int) : Bool
      !!yield
    end

    def visit(c : MinimizeStatement.class, priority : Int) : Bool
      !!yield
    end

    def visit(c : ProjectionStatement.class) : Bool
      !!yield
    end

    def visit(s : OutputString) : Bool
      !!yield
    end

    def visit(pos_lit : Literal, v : External) : Bool
      true
    end

    def visit(c : AssumptionStatement.class) : Bool
      !!yield
    end

    def visit(m : Heuristic, pos_lit : Literal, k : Int, priority : Int) : Bool

      !!yield
    end

    def visit(e : Edge) : Bool
      !!yield
    end

    # Term stuff.

    def visit(c : TheoryStatement) : Bool
      !!yield
    end

    def visit(u : Int, w : TheoryTermNumeric) : Bool
      true
    end

    def visit(u : Int, s : TheoryTermString) : Bool
      true
    end

    def visit(u : Int, t : TheoryTermFunction) : Bool
      !!yield
    end

    # Atom stuff.

    def visit(c : TheoryAtomElement.class, v : Int) : Bool
      !!yield
    end

    def visit(c : TheoryAtom5.class, a : Literal, p : Int) : Bool
      !!yield
    end

    def visit(c : TheoryAtom6.class, a : Literal, p : Int) : Bool
      !!yield
    end

    def visit(o : TheoryAtomOperator, u1 : Int) : Bool
      true
    end

    def visit(c : Comment) : Bool
      true
    end

    def visit(n : IntegerListStart) : Bool
      !!yield
    end

    def visit(n : LiteralListStart) : Bool
      !!yield
    end

    def visit(n : WeightedLiteralListStart) : Bool
      !!yield
    end

    def visit(i : Int) : Bool
      true
    end

    def visit(l : Literal) : Bool
      true
    end

    def visit(l : Literal, w : Int) : Bool
      true
    end

    def initialize(string_or_io_or_char_iterator)
      @helper = Helper.new(string_or_io_or_char_iterator)
    end

    def parse_debug
      parse.tap { |s| s.try { puts s } }
    end

    def parse
      if parse_aspif
        nil
      else
        describe_problem
      end
    end

    private def parse_aspif
      header && logic_program_list && end_of_input
    end

    private describe EXISTING, end_of_input do
      !nilable_cursor
    end

    private describe EXISTING, header do
      asp && (v = version) &&
        visit(Header, v.major, v.minor, v.revision) { tag_list } &&
        newline
    end

    private describe EXISTING, version do
      ((m = nonnegative_integer) &&
       (n = nonnegative_integer) &&
       (r = nonnegative_integer)) ?
      Version.new(m, n, r) :
      nil
    end

    private describe POSSIBLY_EMPTY, tag_list do
      repeated { tag }
    end

    private describe POSSIBLY_EMPTY, logic_program_list do
      repeated { logic_program }
    end

    private describe POSSIBLY_EMPTY, logic_program do
      repeated { statement && newline } &&
        constant('0') && visit(EndOfLogicProgram) && newline
    end

    private describe EXISTING, statement do
      (c = nilable_cursor) && (c != '0') && c.ascii_number? &&
        (t = parse_enum_plain(Statement)) &&
        visit(t) {
          case t
          when Statement::Rule; rule_statement
          when Statement::Minimize; minimize_statement
          when Statement::Projection; projection_statement
          when Statement::Output; output_statement
          when Statement::External; external_statement
          when Statement::Assumption; assumption_statement
          when Statement::Heuristic; heuristic_statement
          when Statement::Edge; edge_statement
          when Statement::Theory; theory_term_or_atom
          when Statement::Comment; comment
          else raise "Internal error"
          end
        }
    end

    # 1 Rule statement

    private describe EXISTING, rule_statement do
      head && body
    end

    private describe EXISTING, head do
      (h = parse_enum(Head)) && visit(h) { literal_list }
    end

    private describe EXISTING, body do
      (c = parse_enum(Body)) &&
        case c
        when Body::Normal
          visit(c) { literal_list }
        when Body::Weight
          (l = positive_integer) && visit(c, l) { weighted_literal_list }
        else
          raise "Internal error"
        end
    end

    # 2 Minimize statement

    private describe EXISTING, minimize_statement do
      (p = integer) && visit(MinimizeStatement, p) { weighted_literal_list }
    end

    # 3 Projection statement

    private describe EXISTING, projection_statement do
      visit(ProjectionStatement) { literal_list }
    end

    # 4 Output statement

    private describe EXISTING, output_statement do
      (s = byte_string) && visit(OutputString.new(s)) { literal_list }
    end

    # 5 External statement

    private describe EXISTING, external_statement do
      (a = positive_literal) && (v = parse_enum(External)) && visit(a, v)
    end

    # 6 Assumption statement

    private describe EXISTING, assumption_statement do
      visit(AssumptionStatement) { literal_list }
    end

    # 7 Heuristic statement

    private describe EXISTING, heuristic_statement do
      (m = parse_enum(Heuristic)) &&
        (a = positive_literal) &&
        (k = integer) &&
        (p = nonnegative_integer) &&
        visit(m, a, k, p) { literal_list }
    end

    # 8 Edge statement

    private describe EXISTING, edge_statement do
      (u = integer) && (v = integer) && visit(Edge.new(u, v)) { literal_list }
    end

    # 9 Theory terms and atoms

    private describe EXISTING, theory_term_or_atom do
      (c = parse_enum(TheoryStatement)) &&
        visit(c) {
          case c
          when TheoryStatement::TermNumeric
            (u = nonnegative_integer) && (w = integer) &&
              visit(u, TheoryTermNumeric.new(w))
          when TheoryStatement::TermString
            (u = nonnegative_integer) && (s = byte_string) &&
              visit(u, TheoryTermString.new(s))
          when TheoryStatement::TermFunction
            (u = nonnegative_integer) && (t = integer) &&
              visit(u, TheoryTermFunction.new(t)) { integer_list }
          when TheoryStatement::AtomElement
            (v = nonnegative_integer) &&
              visit(TheoryAtomElement, v) { integer_list && literal_list }
          when TheoryStatement::Atom5
            (a = positive_literal) && (p = integer) &&
              visit(TheoryAtom5, a, p) { integer_list }
          when TheoryStatement::Atom6
            (a = positive_literal) && (p = integer) &&
              visit(TheoryAtom6, a, p) {
                integer_list && (g = integer) && (u1 = integer) &&
                  visit(TheoryAtomOperator.new(g), u1)
            }
          else
            raise "Internal error"
          end
        }
    end

    # 10 Comment

    private describe EXISTING, comment do
      (s = remaining_line) && visit(Comment.new(s))
    end

    # Strings and lists

    private def byte_string
      (m = nonnegative_integer) ? byte_string(m) : nil
    end

    private describe EXISTING, integer_list do
      (n = nonnegative_integer) ?
        visit(IntegerListStart.new(n)) {
          instances(n) { integer(self) }
        } :
        false
    end

    private describe EXISTING, literal_list do
      (n = nonnegative_integer) ?
        visit(LiteralListStart.new(n)) {
          instances(n) { literal(self) }
        } :
        false
    end

    private describe EXISTING, weighted_literal_list do
      (n = nonnegative_integer) ?
        visit(WeightedLiteralListStart.new(n)) {
          instances(n) { weighted_literal(self) }
        } :
        false
    end

    # Variations of numbers

    private describe EXISTING, integer(visitor) do
      (i = integer) ? visitor.visit(i) : false
    end

    private describe EXISTING, weighted_literal(visitor) do
      # In the format definition, w is a positive integer.
      # However, clasp accepts zero as well as of 2016-12-09.
      # Thus we accept it as well.
      (l = literal) && (w = nonnegative_integer) ? visitor.visit(l, w) : false
    end

    private describe EXISTING, literal(visitor) do
      (l = literal) ? visitor.visit(l) : false
    end

    private describe EXISTING, literal do
      (i = integer) ? Literal.new(i, @helper) : nil
    end

    private describe EXISTING, positive_literal do
      (l = literal) && (l.positive? ? l : nil)
    end

    private describe EXISTING, positive_integer do
      (i = nonnegative_integer) ? check_nonzero(i, "zero integer") : nil
    end

    private def check_nonzero(l, msg)
      if l == 0
        problem(msg)
        nil
      else
        l
      end
    end

    # Misc

    private describe EXISTING, byte_string(m) do
      space ? byte_string_plain(m) : nil
    end

    private def byte_string_plain(m)
      # TODO: Consider putting something like this in the helper.
      while buffer.bytesize < m && nilable_cursor
        step(Append)
      end
      if buffer.bytesize == m
        reap
      else
        problem("managed to read only #{buffer.bytesize} / #{m} bytes")
        nil
      end
    end

    # Low level tokens

    private describe EXISTING, integer do
      integer_silent
    end

    private def integer_silent
      space ?
        (sign = minus ? -1 : 1) &&
        ((n = nonnegative_integer_plain) ?
         sign * n :
         nil) :
        nil
    end

    private describe EXISTING, asp do
      advance_string(Skip, "asp")
    end

    private describe EXISTING, space do
      advance(Skip, ' ')
    end

    private describe EXISTING, newline do
      advance(Skip, '\n') && visit(Newline)
    end

    private def constant(c)
      advance(Skip, c)
    end

    private def minus
      advance(Skip, '-')
    end

    private describe EXISTING, tag do
      space &&
        advance_until(Append, AtLeastOne, &.whitespace?) &&
        visit(Tag.new(reap))
    end

    private describe EXISTING, nonnegative_integer do
      space ? nonnegative_integer_plain : nil
    end

    private def nonnegative_integer_plain
      advance(Append, AtLeastOne, &.ascii_number?) ? reap.to_i : nil
    end

    private describe POSSIBLY_EMPTY, remaining_line do
      space && advance_until(Append, ZeroOrMoreInstancesOf, &.==('\n')) ? reap : nil
    end

    # A helper method for enums.

    private def parse_enum(c : Enum.class)
      space ? parse_enum_plain(c) : nil
    end

    private def parse_enum_plain(c : Enum.class)
      x = nonnegative_integer_plain
      e = c.from_value? x
      unless e
        p =
          c.values.map do |f|
            "#{f.value} for #{f.to_s.underscore.tr("_", " ")}"
          end
        problem("expected #{p.join(", ")}, got #{x}")
      end
      e
    end
  end
end
