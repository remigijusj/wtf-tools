require 'rubygems'
require 'wtf-tools'
require 'pp'
require 'json'
require 'yaml'

WTF.options = {
  :default => Logger.new('./log/example.log'),
  :output => './log/wtf',
}

WTF? 1, Object.new

WTF? 2, :time, :log

WTF? 3, :file

WTF? 4, { :some => 'data', :other => %w(array of items) }, :pp

WTF? 5, { :some => 'data', :other => %w(array of items) }, :json, :nl

WTF? 6, { :some => 'data', :other => %w(array of items) }, :yaml, :no, :file
