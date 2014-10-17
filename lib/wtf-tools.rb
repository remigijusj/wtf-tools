require 'wtf/dumper'
require 'wtf/method_tracker'
require 'wtf/query_tracker'

module WTF
  class << self
    def options=(value)
      @options = value
    end

    def options
      @options ||= {}
    end

    def files_path
      dirs = FileUtils.mkdir_p(options[:files])
      dirs.first
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

    def sql(sql)
      WTF::QueryTracker.start_tracking(sql)
    end

    def time(*args)
      require 'absolute_time'

      precision = args.shift if args.first.is_a?(Fixnum)
      precision ||= 3
      before = AbsoluteTime.now
      result = yield
      duration = AbsoluteTime.now - before
      WTF::Dumper.new(duration.round(precision), *args)
      result
    end
  end
end

Object.class_eval do
  def WTF?(*args)
    WTF::Dumper.new(*args)
    nil
  end
end
