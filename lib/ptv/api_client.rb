# frozen_string_literal: true

require 'httpx'
require 'json'

class APIClientError < StandardError
end

class APIClient
  def initialize
    @dev_id = ENV['DEV_ID']
    @api_key = ENV['API_KEY']
    @base_url = 'https://timetableapi.ptv.vic.gov.au'
    @cache = CACHE
  end

  def request(url)
    cached_resource = @cache.fetch(url)
    return cached_resource if cached_resource

    begin
      resource = fetch_from_api(url)
      @cache.store(url, resource)
      resource
    rescue StandardError => e
      raise APIClientError, e
    end
  end

  def sign(uri)
    uri_with_dev_id = add_dev_id_to(uri)
    # The signature is a HMAC-SHA1 hash of the API key and the request URI (including dev ID, but excluding base URL)
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), @api_key, uri_with_dev_id)
    @base_url + uri_with_dev_id + "&signature=#{signature}"
  end

  private

  def fetch_from_api(url)
    response = HTTPX.get(url)
    raise if response.error # response.error is provided by HTTPX

    JSON.parse(response.body, symbolize_names: true)
  rescue StandardError => e
    raise APIClientError, "Error for `#{url}`: #{e}"
  end

  def add_dev_id_to(uri)
    "#{uri}#{uri.include?('?') ? '&' : '?'}devid=#{@dev_id}"
  end
end
