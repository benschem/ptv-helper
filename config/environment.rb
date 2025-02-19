# frozen_string_literal: true

#########################################################
#                                                       #
#   ENVIRONMENT SETUP                                   #
#                                                       #
#########################################################
#                                                       #
#   Place this file in 'config/environment'             #
#   Require this file in app.rb                         #
#                                                       #
#########################################################

# Require Bundler and set up the load paths
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'] || :development)

# Load environment variables
require 'dotenv'
Dotenv.load

# Require all library files
Dir[File.join(__dir__, '../lib/**/*.rb')].each { |file| require file }

# Setup caching configuration
require './config/caching'
