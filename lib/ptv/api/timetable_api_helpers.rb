module Departures
  def all_departures
    # View departures for all routes from a stop
  end

  def departures_from_stop(stop_id)
    uri = "/v3/departures/route_type/#{@route_type}/stop/#{stop_id}"
    begin
      response = @timetable.request(uri)
      response[:departures]
    rescue TimetableAPIError => e
      raise TransitStop::TransitStopError, "Getting departures from stop failed: #{e}"
    end
  end
end

module Directions
  # View directions that a route travels in

  # View all routes for a direction of travel

  # View all routes of a particular type for a direction of travel
end

module Routes
  # View route names and numbers for all routes
  def routes
    uri = "/v3/routes?route_types=#{@route_type}"
    begin
      response = @timetable.request(uri)
      response[:routes]
    rescue TimetableAPIError => e
      raise TransitStop::TransitStopError, "Getting routes failed: #{e}"
    end
  end
  # View route name and number for specific route ID
end

module Stops
  def stops_for_route(route_id)
    uri = "/v3/stops/route/#{route_id}/route_type/#{@route_type}?route_id=#{route_id}"

    response = @timetable.request(uri)
    response[:stops]
  end
end
