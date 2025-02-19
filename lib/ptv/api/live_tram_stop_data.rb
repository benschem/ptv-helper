# frozen_string_literal: true

require 'json'
require 'httpx'
require 'time'

###########################################################
#                                                         #
#  LIVE TRAM STOP DATA                                    #
#                                                         #
###########################################################
#                                                         #
#  This is a wrapper for the endpoint the QR Codes at     #
#  tram stops call for live timings. It's more accurate   #
#  than the Timetable API data but more limited.          #
#                                                         #
###########################################################
class LiveTramStopData
  class LiveTramStopDataError < StandardError; end

  def initialize(stop_id)
    @stop_id = stop_id
    @url = "https://tramtracker.com.au/QRCode/Controllers/GetNextPredictionsForStop.ashx?stopNo=#{@stop_id}&routeNo=0&isLowFloor=false&ts=1739884891527"
  end

  # returns an array of Time objects representing the next arriving trams
  def next_arrival_times
    response = HTTPX.get(@url)
    trams = JSON.parse(response.body, symbolize_names: true)

    raise LiveTramStopData::LiveTramStopDataError if trams.nil?

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

    timestamp_in_ms = match[1].to_i
    timezone_offset = match[2]

    timestamp_in_seconds = timestamp_in_ms / 1000
    Time.at(timestamp_in_seconds).getlocal(timezone_offset)
  end
end
