require "./spec_helper"

module SpecHelper
  CRYSTAL = %x(which crystal).chomp

  # Runs "crystal eval ..." on a given string and returns the standard input
  # and output contents concatenated in a single string.
  def eval(string) : String
    output = nil
    Process.run(CRYSTAL, ["eval", "--error-trace", string]) do |process|
      output = process.output.gets_to_end + process.error.gets_to_end
    end
    output.not_nil!
  end
end

include SpecHelper

describe SpecHelper do
  it "found CRYSTAL" do
    SpecHelper::CRYSTAL.should_not eq("")
  end

  greeting = "Hello world!"
  program = "print \"#{greeting}\""
  it "evaluates #{program}" do
    eval(program).should eq(greeting)
  end

  program = "1 + :symbol"
  it "evaluates #{program}" do
    eval(program).should match(/Error/)
  end
end
