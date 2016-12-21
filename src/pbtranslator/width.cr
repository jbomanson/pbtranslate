abstract struct PBTranslator::Width(I)
  def self.from_log2(l)
    Pw2.new(log2: l)
  end

  def self.from_pw2(p)
    Pw2.new(pw2: p)
  end

  def self.from_value(v)
    Free.new(value: v)
  end

  abstract def value : I
  abstract def pw2ceil : I
  abstract def log2ceil : I
  abstract def to_pw2 : Pw2(I)
  abstract def to_free : Free(I)

  struct Pw2(I) < Width(I)
    getter log2 : I

    def self.new(*, pw2 : I) forall I
      new(log2: I.zero + (pw2 - 1).popcount)
    end

    def self.new(*, value)
      new(pw2: Math.pw2ceil(value))
    end

    def initialize(*, @log2 : I)
    end

    def pw2
      (I.zero + 1) << log2
    end

    def value : I
      pw2ceil
    end

    def to_pw2 : Pw2(I)
      self
    end

    def to_free : Free(I)
      Free.new(value: value)
    end

    def log2ceil : I
      log2
    end

    def pw2ceil : I
      pw2
    end
  end

  struct Free(I) < Width(I)
    getter value : I

    def initialize(*, @value : I)
    end

    def pw2ceil : I
      Math.pw2ceil(value)
    end

    def log2ceil : I
      to_pw2.log2ceil
    end

    def to_pw2 : Pw2(I)
      Pw2.new(value: value)
    end

    def to_free : Free(I)
      self
    end
  end
end
