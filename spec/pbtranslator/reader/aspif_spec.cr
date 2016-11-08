require "../../spec_helper"

include PBTranslator

RR = Reader::ASPIF

describe Reader::ASPIF do
  it "parses Figure 3. from gekakaosscwa16b" do

    s =
      <<-EOF
      asp 1 0 0
      1 1 1 1 0 0
      1 0 1 2 0 1 1
      1 0 1 3 0 1 -1
      4 1 a 1 1
      4 1 b 1 2
      4 1 c 1 3
      0

      EOF

    RR.new(s).parse.should eq(nil)
  end

  it "parses Figure 4. from gekakaosscwa16b" do

    s =
      <<-EOF
      asp 1 0 0
      1 0 1 1 0 0
      1 0 1 2 0 0
      1 0 1 3 0 0
      1 0 1 4 0 0
      1 0 1 5 0 0
      1 0 1 6 0 0
      4 7 task(1) 0
      4 7 task(2) 0
      4 15 duration(1,200) 0
      4 15 duration(2,400) 0
      9 0 1 200
      9 0 3 400
      9 0 6 1
      9 0 11 2
      9 1 0 4 diff
      9 1 2 2 <=
      9 1 4 1 -
      9 1 5 3 end
      9 1 8 5 start
      9 2 7 5 1 6
      9 2 9 8 1 6
      9 2 10 4 2 7 9
      9 2 12 5 1 11
      9 2 13 8 1 11
      9 2 14 4 2 12 13
      9 4 0 1 10 0
      9 4 1 1 14 0
      9 6 5 0 1 0 2 1
      9 6 6 0 1 1 2 3
      0

      EOF

    RR.new(s).parse.should eq(nil)
  end

  it "parses an arbitrary hand crafter instance" do

    s =
      <<-EOF
      asp 1 0 0 one two three
      2 100 5 1 100 2 200 3 300 4 400 5 500
      1 0 1 1 0 0
      1 0 1 2 0 0
      10 This is a comment.
      1 0 1 3 0 0
      1 0 1 4 0 0
      1 0 1 5 0 0
      1 0 1 6 0 0
      4 7 task(1) 0
      4 7 task(2) 0
      4 15 duration(1,200) 0
      4 15 duration(2,400) 0
      9 0 1 200
      9 0 3 400
      9 0 6 1
      9 0 11 2
      9 1 0 4 diff
      9 1 2 2 <=
      9 1 4 1 -
      9 1 5 3 end
      9 1 8 5 start
      9 2 7 5 1 6
      9 2 9 8 1 6
      9 2 10 4 2 7 9
      9 2 12 5 1 11
      9 2 13 8 1 11
      9 2 14 4 2 12 13
      9 4 0 1 10 0
      9 4 1 1 14 0
      9 6 5 0 1 0 2 1
      9 6 6 0 1 1 2 3
      0

      EOF

    RR.new(s).parse.should eq(nil)
  end

  it "does not accept all nonsense" do

    s = "lkajsdflkajsdf"

    RR.new(s).parse.should_not eq(nil)
  end
end
