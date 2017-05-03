require "../spec_helper"

include PBTranslate

instance_path = "spec/instance/300.aspif"
filter_program = %x(spec/script/find-lpconvert.sh).chomp

instance = File.read(instance_path)

macro describe_translator_class(translator_class)
  translator_class = {{translator_class}}
  describe translator_class do
    it "produces output accepted by #{filter_program}" do
      process = Process.new(filter_program, input: nil, output: false, error: nil)
      begin
        pipe = process.input
        t = translator_class.new(instance, pipe)
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

describe_translator_class(ASPIF::Broker)
describe_translator_class(Tool::CardinalityTranslator)
describe_translator_class(Tool::OptimizationRewriter)
