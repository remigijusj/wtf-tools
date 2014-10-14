require 'rubygems'
require 'wtf-tools'
require 'absolute_time'
require 'fileutils'
require 'csv'

WTF.options = {
  :files => './wtf',
}

class Sample
  def run
    WTF.track(self)
    action1
    action2
    action3
    WTF.track_finish
  end

  def action1
    sleep 1
  end

  def action2
    sleep 2
  end

  def action3
    sleep 3
  end
end

Sample.new.run
