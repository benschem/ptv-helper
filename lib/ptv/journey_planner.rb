# frozen_string_literal: true

require 'openssl'
require 'time'
require_relative 'api_client'
require_relative 'helpers/hash_map'

###########################################################
#                                                         #
#                                                         #
#                                                         #
###########################################################
#                                                         #
#                                                         #
#                                                         #
###########################################################
class JourneyPlanner
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
end
