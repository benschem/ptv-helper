# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/cache/in_memory_cache'

RSpec.describe Cache::InMemoryCache do
  let(:cache)  { Cache::InMemoryCache.new }
  let(:url)    { 'http://example.com/resource' }
  let(:resource) { 'resource_data' }
  let(:fixed_time) { Time.local(2024, 8, 7, 3, 28, 36) }
  let(:expired_time) { fixed_time - cache.instance_variable_get(:@expiration_time) }

  before do
    allow(Time).to receive(:now).and_return(fixed_time)
  end

  describe '#fetch' do
    context 'when the cached item exists' do
      it 'retrieves the item from the cache' do
        cache.store(url, resource)
        expect(cache.fetch(url)).to eq(resource)
      end
    end

    context 'when the cached item does not exist' do
      it 'returns nil' do
        expect(cache.fetch(url)).to eq(nil)
      end
    end

    context 'when the cached item has expired' do
      before { cache.store(url, resource, expired_time) }

      it 'returns nil' do
        expect(cache.fetch(url)).to eq(nil)
      end

      it 'replaces the expired cache item' do
        expect(cache.fetch(url)).to eq(nil)
      end
    end
  end

  describe '#store' do
    it 'stores the resource in the cache' do
      cache_storage = cache.instance_variable_get(:@storage)
      key = cache.send(:hash, url)
      cache.store(url, resource)
      expect(cache_storage[key][:resource]).to eq(resource)
    end

    it 'removes the oldest resource if the cache is full' do
      full_cache = Cache::InMemoryCache.new(max_cache_size: 1)
      full_cache.store('old_url', 'old_resource')
      full_cache.store(url, resource)
      expect(full_cache.fetch('old_url')).to be_nil
      expect(full_cache.fetch(url)).to eq(resource)
    end

    it 'assigns a timestamp to the cached resource' do
      cache.store(url, resource)
      expect(expect(cache.instance_variable_get(:@storage)[cache.send(:hash, url)][:timestamp])).target.to be_a(Time)
    end
  end
end
