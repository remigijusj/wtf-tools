require 'wtf/dumper'
require 'wtf/method_tracker'

module WTF
  # TODO: separately track ActiveRecord finders usage in the related methods
  class << self
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
