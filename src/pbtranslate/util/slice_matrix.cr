# A single contiguous slice treated as a matrix.
#
# The rows of the matrix can be indexed and enumerated as slices.
struct PBTranslate::Util::SliceMatrix(T)
  include Indexable(Slice(T))

  # The number of rows.
  getter rows : Int32

  # The number of columns.
  getter columns : Int32

  # Creates a slice matrix of `rows x columns` elements initialized to values
  # yielded by the given block that is passed row and column indices.
  def initialize(rows r : Int, columns c : Int)
    s = Slice.new((r * c).to_i32) { |i| (yield *i.divmod(c)).as(T) }
    initialize(rows: r, columns: c, slice: s)
  end

  # Creates a slice matrix backed by the given _slice_.
  #
  # The number of elements in the slice must comply with the given shape of the
  # matrix. If either _rows_ or _columns_ is given as zero, it is determined
  # automatically to fill the given slice, if possible.
  def initialize(*, rows r : Int = 0, columns c : Int = 0, @slice : Slice(T))
    s = slice.size
    @rows = r = (c == 0 ? r : s / c).to_i32
    @columns = c = (r == 0 ? c : s / r).to_i32
    n = r * c
    unless n == s
      raise ArgumentError.new(
        "Expected #{r} x #{c} = #{n} elements, got #{s}")
    end
  end

  # The number of elements.
  def elements : Int32
    @slice.size
  end

  # An alias for `rows`.
  def size : Int32
    rows
  end

  # Returns the row slice at _index_.
  protected def unsafe_at(index : Int) : Slice(T)
    row(index)
  end

  # The same as `unsafe_at`.
  private def row(index) : Slice(T)
    rows(index, 1)
  end

  # Returns a slice containing _count_ rows starting at _index_.
  private def rows(index, count) : Slice(T)
    c = @columns
    @slice[c * index, c * count]
  end
end
