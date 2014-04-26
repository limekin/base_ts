require 'bundler/setup'

Bundler.require

require 'net/http'
require 'json'
require './lib/custom_twitter'
require './app'

run Sinatra::Application
