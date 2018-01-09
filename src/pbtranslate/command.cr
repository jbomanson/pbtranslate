require "colorize"
require "option_parser"

require "./config"
require "./scheme/flexible_random_from_depth"
require "./tool/base_scheme"
require "./tool/cardinality_translator"
require "./tool/optimization_rewriter"

private DEFAULT_POPCOUNT_LIMIT = 1
private RANDOM_SEED_DEFAULT    = 0

# A class for processing command line options.
#
# This is based on `Crystal::Command`.
class PBTranslate::Command
  USAGE = <<-USAGE
    Usage: pbtranslate [command] [options] [--] [input file]

    Command:
        translate (default)      translate a file
        measure                  measure a translation
        inspect                  print a network
        help, --help, -h         show this help
        version, --version, -v   show version
    USAGE

  def self.run(options = ARGV)
    new(options).run
  end

  private getter options

  @random_seed_for_random_from_depth = 0

  def initialize(@options : Array(String))
    @use_color = true
  end

  def run
    command = options.first?
    if command
      case
      when "translate".starts_with? command
        options.shift
        translate
      when "measure".starts_with? command
        options.shift
        measure_or_inspect(inspect_please: false)
      when "inspect".starts_with? command
        options.shift
        measure_or_inspect(inspect_please: true)
      when "help".starts_with?(command), "--help" == command, "-h" == command
        puts USAGE
        exit
      when "version".starts_with?(command), "--version" == command, "-v" == command
        puts PBTranslate::Config.description
        exit
      when command.starts_with?("--"), File.file?(command)
        translate
      else
        error "unknown command: #{command}"
      end
    else
      puts USAGE
      exit(1)
    end
  rescue ex : OptionParser::Exception | Errno
    error ex.message
  rescue ex
    puts ex
    ex.backtrace.each do |frame|
      puts frame
    end
    puts
    error "you've found a bug"
  end

  private def translate
    input_filename = nil
    output_filename = nil
    random_seed = RANDOM_SEED_DEFAULT
    scheme_options = SchemeOptions.new(self)
    type = nil
    weight_last = nil
    weight_step = nil

    option_parser =
      OptionParser.parse(options) do |opts|
        opts.banner = "Usage: pbtranslate translate [options] [--] [input file]\n\nOptions:"

        scheme_options.parse(opts)

        opts.on("--type cardinality|optimization|nothing", "Translate cardinality rules, rewrite optimization statements or do nothing.") do |t|
          type = t
        end

        opts.on("--weight-step <p>", "Place weights on every <p>th layer of a comparator network.") do |p|
          weight_step = string_to_i32(p, label: "--weight-step", min: 1)
        end

        opts.on("--weight-last true|false", "Force placement of weights on the last layer of a comparator network. This is true by default.") do |b|
          weight_last = bool_to_i32(b, label: "--weight-last")
        end

        opts.on("--random-seed <s>", "Use <s> as a seed for random number generation.") do |s|
          random_seed = string_to_i32(s, label: "--random-seed")
        end

        opts.on("-o ", "Output filename.") do |o|
          output_filename = o
        end

        opts.on("-h", "--help", "Show this message.") do
          puts opts
          exit
        end

        opts.on("--no-color", "Disable colored output.") do
          @use_color = false
        end
        opts.unknown_args do |before, after|
          remaining = before + after
          unknown_options, filenames = remaining.partition &.starts_with? "--"
          unless unknown_options.empty?
            error "unknown options: #{unknown_options.join(", ")}"
          end
          case filenames.size
          when 0
          when 1
            input_filename = filenames.first
          else
            error "ambiguous input files: #{filenames.join(", ")}"
          end
        end
      end

    initialize_random_seeds(random_seed)

    scheme =
      scheme_options.pick_scheme(
        Random.new(@random_seed_for_random_from_depth),
      )

    with_file_or_io(input_filename, "r", STDIN) do |input_io|
      with_file_or_io(output_filename, "w", STDOUT) do |output_io|
        translator = pick_translator(type, input_io, output_io, scheme)
        if (t = weight_last).is_a?(Bool)
          unless translator.responds_to? :"weight_last="
            error "the --weight-last option is not supported with --type #{type}"
          end
          unless weight_step
            error "the --weight-last option works only with --weight-step"
          end
          translator.weight_last = t
        end
        if p = weight_step
          unless translator.responds_to? :"weight_step="
            error "the --weight-step option is not supported with --type #{type}"
          end
          translator.weight_step = p
        end
        if translator.responds_to? :quick_dry_test
          translator.quick_dry_test
        end
        translate_with(translator)
      end
    end
  end

  private def initialize_random_seeds(random_seed)
    random = Random.new(random_seed)
    @random_seed_for_random_from_depth = random.next_int
  end

  private def pick_translator(type : String | Nil, input_io, output_io, scheme)
    case
    when !type
      error "missing required option --type"
    when "cardinality".starts_with? type
      Tool::CardinalityTranslator.new(scheme, input_io, output_io)
    when "optimization".starts_with? type
      Tool::OptimizationRewriter.new(scheme, input_io, output_io)
    when "nothing".starts_with? type
      ASPIF::Broker.new(input_io, output_io)
    else
      if type
        error "unknown argument '#{type}' to --type"
      else
        error "missing required option --type"
      end
    end
  end

  private def translate_with(translator)
    result = translator.parse
    if result
      # Report a syntax error, but without mentioning "error" twice.
      wo_first = result.split("\n")[1..-1].join("\n")
      error("", extra: wo_first)
    end
  end

  private def with_file_or_io(file : String?, mode : String, io : IO, &block : IO ->)
    if file
      File.open(file, mode, &block)
    else
      block.call(io)
    end
  end

  private def measure_or_inspect(*, inspect_please)
    output_filename = nil
    parameters = Array(String).new
    random_seed = RANDOM_SEED_DEFAULT
    scheme_options = SchemeOptions.new(self)
    subject = nil

    option_parser =
      OptionParser.parse(options) do |opts|
        opts.banner =
          if inspect_please
            "Usage: pbtranslate inspect [options] [--] <parameter>\n\nOptions:"
          else
            "Usage: pbtranslate measure [options] [--] <parameter>\n\nOptions:"
          end

        scheme_options.parse(opts)

        opts.on("--random-seed <s>", "Use <s> as a seed for random number generation.") do |s|
          random_seed = string_to_i32(s, label: "--random-seed")
        end

        description =
          if inspect_please
            "Print a sorting network of width <parameter>."
          else
            "Measure the size and depth of a sorting network of width <parameter>."
          end

        opts.on("--subject 'sorting network'", description) do |s|
          subject = s
        end

        opts.on("-o ", "Output filename.") do |o|
          output_filename = o
        end

        opts.on("-h", "--help", "Show this message.") do
          puts opts
          exit
        end

        opts.on("--no-color", "Disable colored output.") do
          @use_color = false
        end
        opts.unknown_args do |before, after|
          parameters = before + after
        end
      end

    unless subject
      error "expected a --subject option"
    end

    unless subject == "sorting network"
      error "subject can only be 'sorting network' at this time, not #{subject}"
    end

    c = parameters.size
    unless c == 1
      error "expected a single mass argument, got #{c}"
    end

    parameter = string_to_i32(parameters.first, label: "<parameter>", min: 0)

    initialize_random_seeds(random_seed)

    scheme =
      scheme_options.pick_scheme(
        Random.new(@random_seed_for_random_from_depth),
      )

    with_file_or_io(output_filename, "w", STDOUT) do |output_io|
      w = Width.from_value(Distance.new(parameter))
      if inspect_please
        ss = scheme.to_scheme_with_gate_level
        n = ss.network(w)
        n.gates_with_options.each do |(gate, options)|
          case wires = gate.wires
          when Tuple(Distance, Distance)
            i, j = wires
            output_io.puts "comparator(#{i}, #{j}, #{options[:level]})."
          end
        end
      else
        n = scheme.network(w)
        size = Network.compute_gate_count(n)
        depth = scheme.compute_depth(w)
        puts "size: #{size}"
        puts "depth: #{depth}"
      end
    end
  end

  private def bool_to_i32(s : String, *, label : String) : Bool
    d = s.downcase
    case
    when "true".starts_with?(d)  then true
    when "false".starts_with?(d) then false
    else
      error "#{label} must be true or false, not \"#{s}\""
    end
  end

  def string_to_i32(s : String, *, label : String, min bound : Int32 | Nil = nil) : Int32
    unless (i = s.to_i? underscore: true) && (!bound || bound <= i)
      x =
        case bound
        when 1 then "positive integer"
        when 0 then "nonnegative integer"
        else        "signed integer"
        end
      error "#{label} must be a 32 bit #{x}, not \"#{s}\""
    end
    i
  end

  def error(msg, *, extra = "", exit_code = 1, stderr = STDERR)
    c = @use_color && stderr.tty?
    stderr << "pbtranslate: "
    stderr << "error: ".colorize.toggle(c).red.bold
    stderr << msg
    stderr << "\n"
    stderr << extra
    exit(exit_code)
  end
end

private class SchemeOptions
  @crop_depth : Int32 | Nil = nil
  @crop_depth_unit : Int32 | Nil = nil
  @popcount_limit : Int32 = DEFAULT_POPCOUNT_LIMIT
  @network_scheme : String | Nil = nil

  delegate error, to: @command
  delegate string_to_i32, to: @command

  def initialize(@command : Command)
  end

  def parse(opts) : Nil
    opts.on(
      "--network-scheme sorting|random",
      "Use a sorting network or a random comparator network.") do |s|
      @network_scheme = s
    end

    opts.on(
      "--crop-depth <d>",
      "Use first <d> or last -<d> layers of a comparator network." +
      " The value <d> can be given as a percentage as well.") do |d|
      if d.ends_with? '%'
        d = d.rchop
        @crop_depth_unit = 100
      end
      @crop_depth = string_to_i32(d, label: "--crop-depth")
    end

    opts.on(
      "--dynamic-programming-effort <e>",
      "Spend at most 2**<d> fold effort in certain dynamic programming tasks" +
      " when building networks." +
      " Sensible values are between 0 and 32." +
      " The default is #{DEFAULT_POPCOUNT_LIMIT}."
    ) do |e|
      @popcount_limit = string_to_i32(e, label: "--dynamic-programming-effort")
    end
  end

  def pick_scheme(random : Random)
    network_scheme = @network_scheme
    case
    when !network_scheme || "sorting".starts_with? network_scheme
      dynamic_programming_scheme =
        Scheme
          .pw2_merge_odd_even
          .to_scheme_flexible_combine
          .to_scheme_flexible_divide_and_conquer_dynamic_programming(
          Scheme.partial_flexible_sort_hard_coded
        )
      if popcount_limit = @popcount_limit
        dynamic_programming_scheme.popcount_limit = popcount_limit
      end
      scheme = dynamic_programming_scheme.to_scheme_with_offset_resolution
      if crop_depth = @crop_depth
        scheme
          .to_scheme_with_gate_level
          .to_scheme_level_slice &depth_range_proc(crop_depth)
      else
        scheme
      end
    when "random".starts_with? network_scheme
      unless crop_depth = @crop_depth
        error "the --network-scheme random option works only with --crop-depth"
      end
      if @crop_depth_unit
        error "the --network-scheme random option works only with an absolute" +
              "--crop-depth"
      end
      Scheme.flexible_random_from_depth(
        random: random,
        depth: Distance.new(crop_depth),
      )
    else
      error "unknown argument '#{network_scheme}' to --network-scheme"
    end
  end

  private def depth_range_proc(crop_depth : Int32)
    if crop_depth >= 0
      ->(width : Width, depth : Distance) {
        Distance.new(0)...Distance.new(preprocess_depth(crop_depth, depth))
      }
    else
      ->(width : Width, depth : Distance) {
        depth + Distance.new(preprocess_depth(crop_depth, depth))...depth
      }
    end
  end

  private def preprocess_depth(want : Int32, got : UInt32)
    (u = @crop_depth_unit) ? got * want / u : want
  end
end
