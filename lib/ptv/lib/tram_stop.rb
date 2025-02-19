# frozen_string_literal: true

###########################################################
#                                                         #
#                                                         #
#                                                         #
###########################################################
#                                                         #
#                                                         #
#                                                         #
###########################################################
# TramStop.new(stop: 37, direction: ???)
class TramStop < TransitStop
  def initialize(attributes = {})
    super
    @route_type = @route_types[self.class.name.downcase.to_sym]
    @number = attributes[:number]
    @stop = find_stop(@number, attributes[:stop])
    @routes = find_routes(@number)
  end

  def next_arrivals
    LiveTramStopData.new(@stop).next_arrival_times
  end

  # IDEA: USE API TO CALC AVG TIME BETWEEN STOPS

  private

  def find_routes
    all_routes = routes
    all_routes.select { |route| route[:route_number].to_i == @number }
  rescue StandardError => e
    raise TransportError, e
  end

  def find_stop(stop_number)
    stops = get_all_stops_for(@routes)
    stops.find { |stop| stop[:stop_name].include?("##{stop_number}") }
  rescue StandardError => e
    raise TransportError, e
  end
end
