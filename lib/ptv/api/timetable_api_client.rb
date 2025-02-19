# frozen_string_literal: true

require 'httpx'
require 'json'

###########################################################
#                                                         #
#   PUBLIC TRANSPORT VICTORIA TIMETABLE API CLIENT        #
#                                                         #
###########################################################
#                                                         #
#   This is a client for the PTV Timetable API that       #
#   uses a user ID and an API key to calculate and pass   #
#   along the necessary signature in each request.        #
#                                                         #
###########################################################
class TimetableAPIClient
  class TimetableAPIClientError < StandardError; end

  def initialize
    @dev_id = ENV['DEV_ID']
    @api_key = ENV['API_KEY']
    @base_url = 'https://timetableapi.ptv.vic.gov.au'
    @cache = CACHE
  end

  def request(uri)
    url = sign(uri)

    @cache.fetch(url) do
      response = fetch_response(url)
      parse_response(response)
    end
  end

  private

  def fetch_response(url)
    response = HTTPX.get(url)

    if response.status >= 400 || response.error
      raise TimetableAPIClient::TimetableAPIClientClientError,
            "HTTP request failed with status #{response.status}: #{response.error}"
    end

    response
  end

  def parse_response(response)
    JSON.parse(response.body, symbolize_names: true)
  rescue JSON::ParserError => e
    raise TimetableAPIClient::TimetableAPIClientError, "JSON parsing failed: #{e.message}"
  end

  def sign(uri)
    uri_with_dev_id = add_dev_id_to(uri)
    # The signature is a HMAC-SHA1 hash of the API key and the request URI (including dev ID, but excluding base URL)
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), @api_key, uri_with_dev_id)
    @base_url + uri_with_dev_id + "&signature=#{signature}"
  end

  def add_dev_id_to(uri)
    "#{uri}#{uri.include?('?') ? '&' : '?'}devid=#{@dev_id}"
  end
end
