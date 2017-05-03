require "../../spec_helper"

include PBTranslate

medium_number = 10_000
acceptable_size_factor = 1.20
seed = SEED ^ __FILE__.hash

describe Util::IdBroker do
  it "generates 0, 1, ..., #{medium_number}" do
    broker = Util::IdBroker.new
    medium_number.times do |i|
      broker.fresh_id.brokered_id.should eq(i)
    end
  end

  it "maps a random permutation of S = {0, 1, ..., #{medium_number}} to S" do
    random = Random.new(seed)
    broker = Util::IdBroker.new
    a = Array.new(medium_number, &.itself)
    b = a.shuffle(random)
    c =
      Array.new(medium_number) do |i|
        broker.rename(b[i]).brokered_id
      end
    c.sort!
    c.each_index do |i|
      {i, c[i]}.should eq({i, a[i]})
    end
  end

  it "generates and renames compactly and without conflicts" do
    random = Random.new(seed)
    broker = Util::IdBroker.new
    a =
      Array.new(2 * medium_number) do |i|
        {i.odd?, i / 2}
      end
    a.shuffle! random
    b =
      a.map do |(rename_please, index)|
        if rename_please
          broker.rename(index).brokered_id
        else
          broker.fresh_id.brokered_id
        end
      end
    b.sort!
    b.should eq(b.uniq)
    acceptable_size = 2 * medium_number * acceptable_size_factor
    b.max.should be < acceptable_size
  end
end
