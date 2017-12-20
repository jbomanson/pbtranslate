private record In
private IN = In.new

struct PBTranslate::CompileTimeSet(T)
  # Creates a compile time set containing the given identifiers as elements.
  macro create(*args)
    {% begin %}
      PBTranslate::CompileTimeSet.from_option_keys(
        {% for key in args %}
          {{key.id}}: nil,
        {% end %}
      )
    {% end %}
  end

  # Creates a compile time set containing the keys of the given *options* as
  # elements.
  def self.from_option_keys(**options) : CompileTimeSet
    from_named_tuple_type(typeof(options))
  end

  # Creates a compile time set containing the keys of the given
  # *named_tuple_type* as elements.
  def self.from_named_tuple_type(named_tuple_type : U.class) : CompileTimeSet forall U
    {% begin %}
      CompileTimeSet.new(
        nil,
        {% for key in U.keys %}
          {{key}}: IN,
        {% end %}
      )
    {% end %}
  end

  # :nodoc:
  protected def initialize(overload : Nil, **named_tuple : **T)
    {% for key in T.keys %}
      {% unless T[key] == In %}
        {{ raise "Expected all values to be of type In, got #{T[key]}" }}
      {% end %}
    {% end %}
  end

  # Union: returns a new set containing all unique elements from both sets.
  def |(other : CompileTimeSet(U)) : CompileTimeSet forall U
    {% begin %}
      CompileTimeSet.from_option_keys(
        {% for key in (T.keys + U.keys).uniq.sort %}
          {{key}}: IN,
        {% end %}
      )
    {% end %}
  end

  # Intersection: returns a new set containing elements common to both sets.
  def &(other : CompileTimeSet(U)) : CompileTimeSet forall U
    {% begin %}
      CompileTimeSet.from_option_keys(
        {% for key in (T.keys.select { |key| U[key] }).uniq.sort %}
          {{key}}: IN,
        {% end %}
      )
    {% end %}
  end

  # Difference: returns a new set containing elements in this set that are not
  # present in the other.
  def -(other : CompileTimeSet(U)) : CompileTimeSet forall U
    {% begin %}
      CompileTimeSet.from_option_keys(
        {% for key in (T.keys.reject { |key| U[key] }).uniq.sort %}
          {{key}}: IN,
        {% end %}
      )
    {% end %}
  end

  # Symmetric Difference: returns a new set (self - other) | (other - self).
  def ^(other : CompileTimeSet) : CompileTimeSet
    (self - other) | (other - self)
  end

  # Checks at compile time that this set is empty.
  def empty! : Nil
    self.try_nonempty do
      {{
        raise "Expected #{T.keys} to be empty".tr("[]", "{}")
      }}
    end
  end

  # Returns the number of elements in the set.
  def size : Int32
    {{ T.size }}
  end

  # Checks at compile time that this set is a subset of the *other* set.
  def subset!(other : CompileTimeSet(U)) : Nil forall U
    (self - other).try_nonempty do
      {{
        raise "Expected #{T.keys} to be a subset of #{U.keys}".tr("[]", "{}")
      }}
    end
  end

  # Checks at compile time that this set is a superset of the *other* set.
  def superset!(other : CompileTimeSet(U)) : Nil forall U
    (other - self).try_nonempty do
      {{
        raise "Expected #{T.keys} to be a superset of #{U.keys}".tr("[]", "{}")
      }}
    end
  end

  # Evaluates a block if this set contains any elements.
  def try_nonempty(&block)
    {% unless T.keys.empty? %}
      yield self
    {% end %}
  end

  # Writes a string representation of the set to *io*.
  def to_s(io)
    io << '{'
    {% for key, index in T.keys.sort %}
      {% unless index == 0 %}
        io << ", "
      {% end %}
      io << {{key.stringify}}
    {% end %}
    io << '}'
  end
end
