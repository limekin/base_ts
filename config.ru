require 'bundler/setup'

Bundler.require

require 'sinatra'
require 'simple_oauth'
require 'net/http'
require './app'

run Sinatra::Application
