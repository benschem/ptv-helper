# frozen_string_literal: true

require 'json'
require 'openssl'
require_relative '../spec_helper'
require_relative '../../lib/ptv/api/timetable_api_client'

RSpec.describe TimetableAPIClient do
  let(:client) { TimetableAPIClient.new }

  describe '#request' do
    let(:url) { 'http://api.com/resource' }
    let(:response_body) { { data: 'sample data' }.to_json }
    let(:cached_resource) { { resource: JSON.parse(response_body, symbolize_names: true), timestamp: Time.now } }
    let(:fixed_time) { Time.local(2024, 8, 7, 3, 28, 36) }

    before do
      allow(Time).to receive(:now).and_return(fixed_time)
      # allow(HTTPX).to receive(:get).with(url).and_return(double(body: response_body, error: nil))
      # How do any tests pass with this commented out?
    end

    context 'when the resource is cached' do
      it 'returns the cached resource' do
        cache = client.instance_variable_get(:@cache)
        cache_storage = cache.instance_variable_get(:@storage)
        key = client.instance_variable_get(:@cache).send(:hash, url)
        cache_storage[key] = cached_resource
        expect(client.request(url)).to eq(data: 'sample data')
      end
    end

    context 'when the resource is not cached' do
      it 'fetches the resource from the API' do
        expect(client.request(url)).to eq(data: 'sample data')
      end

      it 'stores the resource in the cache' do
        client.request(url)

        cache = client.instance_variable_get(:@cache)
        cache_storage = cache.instance_variable_get(:@storage)
        key = cache.send(:hash, url)

        expect(cache_storage[key]).to eq(cached_resource)
      end
    end

    context 'when the API request fails' do
      it 'raises an error if the response contains an exception or a 4xx or 5xx error' do
        # allow(HTTPX).to receive(:get).with(url).and_return(HTTPX::ErrorResponse)
        # binding.pry
        # These tests are not passing and it's because stubbing HTTPX.get does not apply inside client.request
        # I don't know why
        expect { client.request(url) }.to raise_error(APIClientError)
      end

      it 'raises an error if the response body can\'t be parsed into JSON' do
        # allow(HTTPX).to receive(:get).with(url).and_return(double(body: '', error: nil))
        # These tests are not passing and it's because stubbing HTTPX.get does not apply inside client.request
        # I don't know why
        expect { client.request(url) }.to raise_error(APIClientError)
      end
    end
  end

  describe '#sign' do
    let(:uri) { '/v3/routes' }
    let(:api_key) { 'test_api_key' }
    let(:dev_id) { 'test_dev_id' }
    let(:base_url) { 'https://timetableapi.ptv.vic.gov.au' }
    let(:signature) { 'test_signature' }

    before do
      allow(client).to receive(:base_url).and_return(base_url)
      allow(client).to receive(:api_key).and_return(api_key)
      allow(client).to receive(:dev_id).and_return(dev_id)
    end

    context 'URI without query parameters' do
      let(:uri) { '/v3/routes' }

      it 'returns a correctly signed URL' do
        allow(client).to receive(:add_dev_id_to).with(uri).and_return("#{uri}?devid=#{dev_id}")
        allow(OpenSSL::HMAC).to receive(:hexdigest).with(OpenSSL::Digest.new('sha1'), @api_key,
                                                         "#{uri}?devid=#{dev_id}").and_return(signature)
        expected_url = "#{base_url}#{uri}?devid=#{dev_id}&signature=#{signature}"
        expect(client.send(:sign, uri)).to eq(expected_url)
      end
    end

    context 'URI with query parameters' do
      let(:uri) { '/v3/routes?route_type=0' }

      it 'returns a correctly signed URL' do
        allow(client).to receive(:add_dev_id_to).with(uri).and_return("#{uri}&devid=#{dev_id}")
        allow(OpenSSL::HMAC).to receive(:hexdigest).with(OpenSSL::Digest.new('sha1'), @api_key,
                                                         "#{uri}&devid=#{dev_id}").and_return(signature)
        expected_url = "#{base_url}#{uri}&devid=#{dev_id}&signature=#{signature}"
        expect(client.send(:sign, uri)).to eq(expected_url)
      end
    end
  end
end
