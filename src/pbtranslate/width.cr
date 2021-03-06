abstract struct PBTranslate::Width
  def self.from_log2(l)
    Pw2.new(log2: l)
  end

  def self.from_pw2(p)
    Pw2.new(pw2: p)
  end

  def self.from_value(v)
    Flexible.new(value: v)
  end

  abstract def value : Distance
  abstract def pw2ceil : Distance
  abstract def log2ceil : Distance
  abstract def to_pw2 : Pw2
  abstract def to_free : Flexible

  struct Pw2 < Width
    getter log2 : Distance

    def self.new(*, pw2 : Distance)
      if pw2 == 0
        raise ArgumentError.new("Expected a power of two, got #{pw2}")
      end
      new(log2: Distance.zero + (pw2 - 1).popcount)
    end

    def self.new(*, value)
      new(pw2: Math.pw2ceil(value))
    end

    def initialize(*, @log2 : Distance)
    end

    def pw2 : Distance
      Distance.new(1) << log2
    end

    def value : Distance
      pw2ceil
    end

    def pw2ceil : Distance
      pw2
    end

    def log2ceil : Distance
      log2
    end

    def to_pw2 : Pw2
      self
    end

    def to_free : Flexible
      Flexible.new(value: value)
    end
  end

  struct Flexible < Width
    getter value : Distance

    def initialize(*, @value : Distance)
    end

    def pw2ceil : Distance
      Math.pw2ceil(value)
    end

    def log2ceil : Distance
      to_pw2.log2ceil
    end

    def to_pw2 : Pw2
      Pw2.new(value: value)
    end

    def to_free : Flexible
      self
    end
  end
end
