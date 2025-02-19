# frozen_string_literal: true

#########################################################
#                                                       #
#   MODULAR CACHE                                       #
#                                                       #
#########################################################
#                                                       #
#   Place this file in 'config/caching'                 #
#   Require this file in envrionment.rb or app.rb       #
#                                                       #
#########################################################

require_relative '../lib/cache/in_memory_cache'

# Set the Cache module.
# Default is InMemoryCache
CACHE = Cache::InMemoryCache.new

# Or choose which cache to use based on your environment
# or configuration:
# CACHE = if ENV['CACHE_TYPE'] == 'OtherCacheModule'
#           Cache::OtherCacheModule
#         else
#           Cache::InMemoryCache.new
#         end

# Set maximum size for cache.
# Default is 100
# CACHE.max_cache_size = 100

# Set expiration time in seconds for cached_items.
# Default is 3600 seconds (1 hour)
# CACHE.expiration_time = 3600

## TODO: Background job that clears expired cached resources
#
#
