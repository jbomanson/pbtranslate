abstract struct PBTranslator::Width
  def self.from_log2(l)
    Pw2.new(log2: l)
  end

  def self.from_pw2(p)
    Pw2.new(pw2: p)
  end

  def self.from_value(v)
    Free.new(value: v)
  end

  abstract def value : Distance
  abstract def pw2ceil : Distance
  abstract def log2ceil : Distance
  abstract def to_pw2 : Pw2
  abstract def to_free : Free

  struct Pw2 < Width
    getter log2 : Distance

    def self.new(*, pw2 : Distance)
      new(log2: Distance.zero + (pw2 - 1).popcount)
    end

    def self.new(*, value)
      new(pw2: Math.pw2ceil(value))
    end

    def initialize(*, @log2 : Distance)
    end

    def pw2
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

    def to_free : Free
      Free.new(value: value)
    end
  end

  struct Free < Width
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

    def to_free : Free
      self
    end
  end
end
