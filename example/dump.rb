require 'rubygems'
require 'wtf-tools'
require 'pp'
require 'json'
require 'yaml'
require 'active_support/logger'
require 'fileutils'

WTF.options = {
  :default => ActiveSupport::Logger.new('./example.log'),
  :files => './wtf',
}

data = { 'some' => { 'nested' => { 'data' => 17 } }, :question => %w(life universe and everything), :answer => 42 }

WTF? Time.now

WTF? :label, "string", 17, 2.0001, :time, :nl

WTF? 'label', "string", 17, 2.0001, :time, :line, :nl

WTF? data, :pp, :nl

WTF? data, :json, :nl

WTF? data, :yaml, :no, :file

data.wtf(:file).size
