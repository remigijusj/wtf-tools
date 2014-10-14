require 'rubygems'
require 'wtf-tools'
require 'pp'
require 'json'
require 'yaml'
require 'logger'
require 'fileutils'

WTF.options = {
  :default => Logger.new('./example.log'),
  :files => './wtf',
}

WTF? 1, Object.new

WTF? 2, :some, "string", 17, :time

WTF? 3, :file

WTF? 4, { :some => 'data', :other => %w(array of items) }, :pp

WTF? 5, { :some => 'data', :other => %w(array of items) }, :json, :nl

WTF? 6, { :some => 'data', :other => %w(array of items) }, :yaml, :no, :file
