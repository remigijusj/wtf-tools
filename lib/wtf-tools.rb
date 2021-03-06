require_relative 'wtf/dumper'
require_relative 'wtf/method_tracker'
require_relative 'wtf/query_tracker'

module WTF
  class << self
    def options=(value)
      @options = value
    end

    def options
      @options ||= {}
    end

    def files_path
      if options[:files]
        dirs = FileUtils.mkdir_p(options[:files])
        dirs.first
      else
        Dir.getwd
      end
    end

    def output_options
      Hash(options[:output])
    end

    # TODO: separately track ActiveRecord finders usage in the related methods
    def track(*objects)
      WTF::MethodTracker.start_tracking(*objects)
      if block_given?
        yield
        track_finish
      end
    end

    def track_finish
      WTF::MethodTracker.finish
    end

    def sql(*args)
      WTF::QueryTracker.start_tracking(*args)
    end

    def time(*args)
      require 'absolute_time'

      precision = args.shift if args.first.is_a?(Fixnum)
      precision ||= 3
      before = AbsoluteTime.now
      result = yield
      duration = AbsoluteTime.now - before
      WTF::Dumper.new(duration.round(precision), *args).call
      result
    end
  end
end

Object.class_eval do
  def WTF?(*args)
    WTF::Dumper.new(*args).call
    nil
  end

  def wtf(*args)
    WTF::Dumper.new(self, *args).call
    self
  end
end
