require 'rubygems'
require 'wtf-tools'
require 'active_support/logger'

# default: puts
WTF.time {
  sleep 1.01
}

# logging time with specified precision and options
WTF.options = {
  :default => ActiveSupport::Logger.new('./example.log'),
}
result = WTF.time(4, :nl) {
  sleep 3.12346
  17
}
p result # => 17
