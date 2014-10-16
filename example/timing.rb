require 'rubygems'
require 'wtf-tools'
require 'active_support/logger'

WTF.options = {
  :default => ActiveSupport::Logger.new('./example.log'),
}

WTF.time(2) {
  sleep 1.01
}

result = WTF.time(4, :nl) {
  sleep 3.12346
  17
}

p result # => 17
