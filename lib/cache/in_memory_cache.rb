# frozen_string_literal: true

require 'digest/md5'
require 'time'

module Cache
  ##########################################################
  #                                                         #
  #   IN MEMORY CACHE                                       #
  #                                                         #
  ###########################################################
  #                                                         #
  #   Stores resources in a Hash in memory until they       #
  #   expire or until the cache fills up.                   #
  #                                                         #
  ###########################################################
  class InMemoryCache
    attr_accessor :max_size, :expiration_time

    def initialize(attributes = {})
      @storage = {}
      @max_size = attributes[:max_cache_size] || 100
      @expiration_time = attributes[:expiration_time] || 3600
    end

    def fetch(url)
      delete_expired_cache_for(url) if cache_expired?(url)

      cached_resource = get_cached_resource_for(url)
      return nil if cached_resource.nil?

      cached_resource
    end

    def store(url, resource, timestamp = Time.now)
      delete_oldest_cached_resource if cache_is_full?

      cached_resource = { resource: resource, timestamp: timestamp }
      add_to_cache(url, cached_resource)
    end

    private

    def add_to_cache(url, cached_resource)
      key = hash(url)
      @storage[key] = cached_resource
    end

    def hash(url)
      Digest::MD5.hexdigest(url)
    end

    def get_cached_resource_for(url)
      key = hash(url)
      return nil unless @storage[key]

      @storage[key][:resource]
    end

    def delete_expired_cache_for(url)
      key = hash(url)
      @storage.delete(key)
    end

    def cache_expired?(url)
      key = hash(url)
      cached_item = @storage[key]
      return false if @storage[key].nil?

      timestamp = cached_item[:timestamp]
      time_stored = Time.now - timestamp
      time_stored >= @expiration_time
    end

    def delete_oldest_cached_resource
      oldest_resource = @storage.keys.min_by { |key| @storage[key][:timestamp] }
      @storage.delete(oldest_resource)
    end

    def cache_is_full?
      @storage.size >= @max_size
    end
  end
end
