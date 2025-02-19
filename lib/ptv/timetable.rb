# frozen_string_literal: true

require 'openssl'
require 'time'
require_relative 'api_client'
require_relative 'helpers/hash_map'

class ResponseError < StandardError
end

class Timetable
  def initialize
    @api = APIClient.new
    @route_types = {
      train: 0,
      tram: 1,
      bus: 2,
      vline: 3,
      night_bus: 4
    }
  end

  def find_matching_arrivals(departures_for_stop, departures_for_other_stop)
    departure_map_for_other_stop = HashMap.group_by_run_ref_and_route_id(departures_for_other_stop)

    # flat_map is used to transform each departure into a list of matched pairs
    # and then flatten the result into a single list.
    # For each departure
    departures_for_stop.flat_map do |departure|
      # Create a key using the departure's run_ref and route_id
      key = [departure[:run_ref], departure[:route_id]]
      # Look up this key in departure_map to get the matched arrival
      matched_arrival_for_departure = departure_map_for_other_stop[key] || []
      matched_arrival_for_departure.map do |matched_arrival|
        { departure: departure, arrival: matched_arrival }
      end
    end
  end

  def get_all_future_tram_departures_from(stop)
    all_departures = get_departures_from(stop)
    all_departures.select do |departure|
      departure_time = Time.parse(departure[:scheduled_departure_utc]).utc.iso8601
      departure_time > Time.now.utc.iso8601
    end
  rescue StandardError => e
    raise ResponseError, e
  end

  def find_tram_stop(attributes = {})
    stop_number = attributes[:stop_number]
    tram_number = attributes[:tram_number]
    route = find_tram_route_for(tram_number)
    stops = get_all_stops_for(route)
    stops.find { |stop| stop[:stop_name].include?("##{stop_number}") }
  rescue StandardError => e
    raise ResponseError, e
  end

  def get_route_number_for(route_id)
    uri = "/v3/routes/#{route_id}"
    url = @api.sign(uri)
    begin
      response_body = @api.request(url)
      response_body[:route][:route_number]
    rescue APIClientError => e
      raise ResponseError, e
    end
  end

  private

  def find_tram_route_for(tram_number)
    tram_routes = get_routes_for(:tram)
    tram_routes.find { |route| route[:route_number].to_i == tram_number }
  rescue StandardError => e
    raise ResponseError, e
  end

  # when called transport_type should be :train, :tram, etc
  def get_routes_for(route_type)
    type = @route_types[route_type].to_s
    uri = "/v3/routes?route_types=#{type}"
    url = @api.sign(uri)
    begin
      response_body = @api.request(url)
      response_body[:routes]
    rescue APIClientError => e
      raise ResponseError, e
    end
  end

  def get_departures_from(stop)
    uri = "/v3/departures/route_type/#{stop[:route_type]}/stop/#{stop[:stop_id]}"
    url = @api.sign(uri)
    begin
      response_body = @api.request(url)
      response_body[:departures]
    rescue APIClientError => e
      raise ResponseError, e
    end
  end

  def get_all_stops_for(route)
    uri = "/v3/stops/route/#{route[:route_id]}/route_type/#{route[:route_type]}?route_id=#{route[:route_id]}"
    url = @api.sign(uri)
    begin
      response_body = @api.request(url)
      response_body[:stops]
    rescue APIClientError => e
      raise ResponseError, e
    end
  end
end
