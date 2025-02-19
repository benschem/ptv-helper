# frozen_string_literal: true

require 'json'
require 'httpx'
require 'time'

class ScraperError < StandardError
end

# Does some shit
class Scraper
  def initialize(stop_id)
    @stop_id = stop_id
    @url = "https://tramtracker.com.au/QRCode/Controllers/GetNextPredictionsForStop.ashx?stopNo=#{@stop_id}&routeNo=0&isLowFloor=false&ts=1739884891527"
    # @cache = CACHE
  end

  # returns an array of Time objects representing the next arriving trams
  def fetch_next_tram_times
    # cached_resource = @cache.fetch(@url)
    # return cached_resource if cached_resource

    response = HTTPX.get(@url)
    trams = JSON.parse(response.body, symbolize_names: true)

    raise ScraperError if trams.nil?

    trams[:responseObject].map do |trip|
      {
        route_number: trip[:RouteNo],
        arrival_time: parse_time(trip[:PredictedArrivalDateTime])
      }
    end
  end

  private

  # The times come back as strings in a Microsoft format:
  # "/Date(1739903520000+1100)/"
  def parse_time(date_str)
    match = date_str.match(%r{/Date\((\d+)([+-]\d{4})\)/})
    return nil unless match

    timestamp_ms = match[1].to_i
    timezone_offset = match[2]

    # Convert milliseconds to seconds
    timestamp_s = timestamp_ms / 1000

    # Convert to Time object and apply timezone
    Time.at(timestamp_s).getlocal(timezone_offset)
  end
end
