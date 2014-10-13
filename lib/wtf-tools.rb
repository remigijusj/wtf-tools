require 'wtf/dumper'
require 'wtf/method_tracker'

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
      WTF::MethodTracker.setup_tracking(*objects)
      WTF::MethodTracker.reset_state
      if block_given?
        yield
        track_finish
      end
    end

    def track_finish
      WTF::MethodTracker.finish
    end
  end
end

Object.class_eval do
  def WTF?(*args)
    WTF::Dumper.new(*args)
  end
end
