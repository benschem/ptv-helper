module Departures
  def all_departures
    # View departures for all routes from a stop
  end

  def departures_for_route(route)
    # View departures for a specific route from a stop
  end
end

module Directions
  def directions
    DirectionsAPI.new(@stop_id)
  end
end
