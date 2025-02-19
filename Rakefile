# frozen_string_literal: true

# List Rake tasks with:
# rake -T

namespace :middleware do
  desc 'List all Rack middleware used in the Sinatra app'

  # rake middleware:list
  task :list do
    require_relative 'app'

    middlewares = Sinatra::Application.middleware

    puts 'Rack Middleware Stack:'
    if middlewares.any?
      middlewares.each_with_index do |middleware, index|
        puts "#{index + 1}. #{middleware}"
      end
    else
      puts 'No middleware.'
    end
  end
end
