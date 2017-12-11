require "../spec_helper"

include PBTranslate

private INSTANCE_PATH  = "spec/instance/300.aspif"
private FILTER_PROGRAM = %x(spec/script/find-lpconvert.sh).chomp

private INSTANCE = File.read(INSTANCE_PATH)

def describe_translator_class(translator_class)
  describe translator_class do
    it "produces output accepted by #{FILTER_PROGRAM}" do
      process = Process.new(FILTER_PROGRAM, input: nil, output: false, error: nil)
      begin
        pipe = process.input
        t = translator_class.new(INSTANCE, pipe)
        t.parse
        status = process.wait
        status.exit_code.should eq(0)
      rescue ex
        process.error.gets_to_end.should eq("")
        process.kill rescue Errno
        raise ex
      end
    end
  end
end

describe "FILTER_PROGRAM" do
  it "is found on the system" do
    FILTER_PROGRAM.should_not eq("")
  end
end

describe_translator_class(ASPIF::Broker)
describe_translator_class(Tool::CardinalityTranslator)
describe_translator_class(Tool::OptimizationRewriter)
