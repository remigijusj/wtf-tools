module WTF
  class Dumper
    PREFIX_OPTIONS = [:time, :nl, :no].freeze
    FORMAT_OPTIONS = [:pp, :yaml, :json, :text, :line, :csv].freeze
    MODIFY_OPTIONS = [:bare].freeze
    OUTPUT_OPTIONS = [:puts, :error, :file].freeze

    OPTIONS = (PREFIX_OPTIONS + FORMAT_OPTIONS + MODIFY_OPTIONS + OUTPUT_OPTIONS).freeze

    attr_reader :options

    def initialize(*args)
      @options = {}
      while is_option?(args.last)
        @options[args.pop] = true
      end
    end

    def call
      data = prefix(args) << format(args)
      output(data)
    end

    private

    def is_option?(sym)
      OPTIONS.include?(sym) or WTF.output_options.key?(sym)
    end

    def prefix(args)
      data = ''
      return data if options[:no]
      data << "\n" if options[:nl]
      data << "[%s] " % Time.now if options[:time]
      data << if args[0].is_a?(Symbol)
        args.shift.to_s.upcase
      else
        pattern = %r{([^/]+?)(?:\.rb)?:(\d+):in `(.*)'$}  # '
        "WTF (%s/%s:%s)" % caller[3].match(pattern).values_at(1,3,2)
      end
      data << ': '
    end

    def format(args)
      case
      when options[:pp]
        cleanup(args.pretty_inspect, options[:bare])
      when options[:yaml]
        YAML.dump(args)
      when options[:json]
        JSON::pretty_generate(args)
      when options[:text]
        args.map(&:to_s).join("\n")
      when options[:line]
        args.map(&:inspect).join("\n  ")
      when options[:csv]
        args[0].map(&:to_csv).join
      else
        cleanup(args.inspect, options[:bare])
      end
    end

    def cleanup(str, bare = false)
      # remove array parentheses
      str.gsub!(/^\[|\]$/,'')
      # ActiveRecord no attributes
      str.gsub!(/#<[A-Z]\w+ id: \d+\K.*?>/, '>') if bare
      str
    end

    def output(data)
      selected = (OUTPUT_OPTIONS + WTF.output_options.keys).select { |how| options[how] }
      selected << :default if selected.empty?
      selected.each do |how|
        Output.new(data).call(how)
      end
    end

    class Output
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def call(meth)
        if block = WTF.output_options[meth]
          block.call(meth)
        else
          send(meth)
        end
      end

      private

      def puts
        STDOUT.puts(data)
      end
      alias_method :default, :puts

      def file
        time = Time.now.strftime('%m%d_%H%M%S')
        file = File.join(WTF.files_path, "wtf_#{time}_#{rand(10000)}.txt")
        File.write(file, data)
      end

      def error
        raise StandardError, data
      end
    end
  end
end
