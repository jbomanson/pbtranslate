# TODO: Optimize the case of constant width strings in Helper with an eye on
# lighter error checking.

module PBTranslator

  class Reader::Helper
  end

  module Reader::Helper::Name
    macro delegate_helper_methods_to(field)
      delegate(
        advance,
        advance_until,
        optional,
        at_least_one,
        buffer,
        cursor,
        describe_problem,
        instances,
        nilable_cursor,
        otherwise,
        scope,
        reap,
        consists_of,
        repeated,
        step,
        switch,
        to: {{field.id}},
      )
    end

    module Action
    end

    struct Skip
      extend Action
    end

    struct Append
      extend Action
    end

    module Count
      # Yields a block some number of times or until it returns false.
      def until_done
        n = 0
        while !(done? n) && (yield n)
          n += 1
        end
        enough? n
      end

      abstract def enough?(n)
      abstract def done?(n)
    end

    struct OneInstanceOf
      extend Count

      def self.enough?(n)
        n == 1
      end

      def self.done?(n)
        n >= 1
      end
    end

    struct ZeroOrMoreInstancesOf
      extend Count

      def self.enough?(n)
        true
      end

      def self.done?(n)
        false
      end
    end

    struct AtLeastOne
      extend Count

      def self.enough?(n)
        n >= 1
      end

      def self.done?(n)
        false
      end
    end


    struct Exactly
      include Count

      def initialize(@n : Int32)
      end

      def enough?(n)
        @n == n
      end

      def done?(n)
        @n == n
      end
    end

    struct CountRange
      include Count

      def initialize(range : Range(Int32, Int32))
        @a = range.begin
        @b = range.end + range.exclusive? ? 0 : 1
      end

      def enough?(n)
        @a <= n
      end

      def done?(n)
        @b >= n
      end
    end

    # Error handling.

    record MatchKind, missing : String, partial : String

    # DSL.

    macro advance_string(action, string)
      advance({{action}}, { {{string.chars.splat}} })
    end

    macro describe(name)
      def {{name.id}}
        {{yield}}
      end
    end

    macro describe(kind, name, *rest)
      def {{name.id}}
        scope(
          {{kind}},
          {{name.
            stringify.
            gsub(/\s+.*/, "").
            gsub(/_/, " ").
            gsub(/\(.*\)$/, "") }},
            {{*rest}}) do

          {{yield}}
        end
      end
    end
  end

  class Reader::Helper
    include Name

    record Position, line : Int32 = 1, column : Int32 = 1 do
      def bump(c : Char)
        if c == '\n'
          Position.new(line + 1, 1)
        else
          Position.new(line, column + 1)
        end
      end

      def to_s(io)
        io << "line "
        io << line
        io << ", "
        io << "column "
        io << column
      end
    end

    abstract struct Problem
    end

    struct BasicProblem < Problem
      def initialize(@kind : MatchKind, @context : String, @position : Position)
      end

      def to_s(io, relative_to final_position, basic)
        b = (@position == final_position)
        io << "one "
        if basic
          io << (b ? @kind.missing : @kind.partial)
          io << ' '
        end
        io << @context
        io << " at "
        io << @position
      end
    end

#    struct SwitchProblem < Problem
#      def initialize
#        @cases = Array({kind: MatchKind, context: String}).new
#      end
#
#      def to_s(io, *args, **options)
##        s = ""
##        @cases.reverse_each do |c|
##          io << s
##          io << c[:kind].missing
##          io << c[:context]
##          io << '\n'
##          s = "\tor "
##        end
#        io
#      end
#
#      def add_case(kind : MatchKind, context : String)
#        @cases << {kind: kind, context: context}
#        self
#      end
#    end

    struct PrescribedProblem < Problem
      getter message

      def initialize(@message : String)
      end

      def to_s(io, *args, **options)
        io << @message
      end
    end

    def self.new(s : String | IO, *args, **options)
      self.new(s.each_char, *args, **options)
    end

    getter iterator
    getter cursor
    getter buffer

    @cursor : Char | Iterator::Stop

    def initialize(
      @iterator : Iterator(Char),
      *,
      @buffer : IO::Memory = IO::Memory.new)

      @cursor_position = Position.new
      @cursor = @iterator.next
      @problem_stack = Array(Problem).new
      @destined = true
    end

    # Non-consuming checks.

    # Returns the current cursor character or nil if there are none left.
    def nilable_cursor : Char?
      c = @cursor
      (c.is_a? Char) ? c : nil
    end

    # Conditional reading.

    def advance(action : Action, c : Char)
      advance(action, OneInstanceOf, &.==(c))
    end

    def advance(action : Action, e : Enumerable)
      e.all? do |c|
        advance(action, c)
      end
    end

#    def advance(action : Action, a : Indexable(Char))
#      instances(a.size) do |i|
#        advance(action, a[i])
#      end
#    end

#    def advance(action : Action, s : String | IO)
#      # NOTE: This might not work when the cursor = Iterator::Stop and s = "".
#      # TODO: Check whether it works or not.
#      iterator = s.each_char
#      advance(action, ZeroOrMoreInstancesOf) do |c|
#        d = iterator.next
#        return true if iterator.stop == d
#        c == d
#      end
#      false
#    end

    def advance_until(*args)
      advance(*args) do |c|
        !(yield c)
      end
    end

   def advance(action : Action, count : Count)
     count.until_done do |n|
       c = nilable_cursor
       if c && (yield c)
         step(action)
         true
       else
         false
       end
     end
    end

    # Yields a block and returns true if the block returned true or if it did
    # not advance the cursor.
    #
    # In other words, this returns true if all or nothing matched.
    # The expression `optional { ... }` is the same as `switch { ... ||
    # otherwise && true }` with the exception that it always returns a boolean.
    def optional
      switch_raw_pair { yield }.last
    end

    # Block repetition.

    # Yields a block up to a given number of times and returns true if the
    # block returned true sufficiently many times.
    def consists_of(count : Count)
      count.until_done do |n|
        if count.enough? n
          r, g = switch_raw_pair { yield n }
          break false unless g
          r
        else
          # TODO: If this fails, an error message with "one" in it may be
          # misleading. It might be better as "one or more" in some cases.
          yield n
        end
      end
    end

    def instances(k : Int)
      consists_of(Exactly.new(k)) { |n| yield n }
    end

    def instances(range : Range)
      consists_of(CountRange.new(range)) { |n| yield n }
    end

    def consists_of(*args)
      instances(*args) { |n| yield n }
    end

    def repeated
      consists_of(ZeroOrMoreInstancesOf) { |n| yield n }
    end

    # TODO: Implement at_least(x) { ... }.
    def at_least_one
      consists_of(AtLeastOne) { |n| yield n }
    end

#    # Yields a block up to a given number of times and returns true if the
#    # block returned true every time.
#    def instances(n : Int)
#      r = true
#      i = typeof(n).new(0)
#      while r && (i < n)
#        r = yield(i)
#        i += 1
#      end
#      r
#    end

    def reap : String
      @buffer.to_s.tap do
        @buffer.clear
      end
    end

    # Unconditional reading.

    def step
      step(Skip)
    end

    def step(action : Append.class)
      c = nilable_cursor
      raise "Attempt to append nothing" unless c
      @buffer << c
      step
    end

    def step(action : Skip.class) : Void
      @cursor_position = @cursor_position.bump(nilable_cursor.not_nil!)
      @cursor = @iterator.next
      @destined = true
    end

    # Error handling.

    def switch : Bool
      switch_raw { yield }
#      @destined = false
#      r = yield
#      unless r || @destined
#        @problem_stack << SwitchProblem.new
##        if yield
##          raise "First switch succeeded, second identical switch failed"
##        end
#      end
#      @destined = true
#      r
    end

#    def switch : Bool
#      switch_raw do
#        yield.tap do |v|
#          unless v || @destined #|| (@problem_stack.last?.is_a? SwitchProblem)
#            @destined = true
#            @problem_stack << SwitchProblem.new
#            if switch_raw { yield }
#              raise "First switch succeeded, second identical switch failed"
#            end
#          end
#          false
#        end
#      end
#    end

    def otherwise : Bool
      !@destined
    end

    private def switch_raw_pair
      switch_raw do
        r = yield
        {r, r || !@destined}
      end
    end

    # NOTE: This might be presently used only in switch.
    private def switch_raw
      s = @destined
      @destined = false
      r = yield
      @destined ||= s
      r
    end

    def problem(string) : Void
      @problem_stack << PrescribedProblem.new(string)
    end

    def scope(kind, context)
      position = @cursor_position
      yield.tap do |v|
        if !v
          note_problem(kind, context, position)
        end
        if v && !@problem_stack.empty?
          raise "Found success and a problem: #{describe_problem}"
        end
      end
    end

    private def note_problem(kind, context, position) : Void
      return unless @destined
#      t = @problem_stack.last?
#      if t.is_a? SwitchProblem
#        t.add_case(kind, context)
#      else
        @problem_stack << BasicProblem.new(kind, context, position)
#      end
    end

    def describe_problem
      final_position = @cursor_position
      if @problem_stack.empty?
        raise "There are no problem descriptions"
      end
      basic = @problem_stack.first.is_a? BasicProblem
      String.build do |str|
        str << "Syntax error:\n"
        s = ""
        @problem_stack.each do |problem|
          str << '\t'
          str << s
          problem.to_s(str, relative_to: final_position, basic: basic)
          str << '\n'
          s = "in "
        end
      end
    end
  end
end
