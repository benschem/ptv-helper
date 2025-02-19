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
class TransitStop
  class TransitStopError < StandardError; end

  def initialize
    @timetable = TimetableAPIClient.new
    @route_types = {
      train: 0,
      tram: 1,
      bus: 2,
      vline: 3,
      night_bus: 4
    }
  end

  private

  def filter_future_departures(departures)
    departures.select do |departure|
      departure_time = Time.parse(departure[:scheduled_departure_utc]).utc.iso8601
      departure_time > Time.now.utc.iso8601
    end
  rescue StandardError => e
    raise TransitStop::TransitStopError, "Filtering future departures failed: #{e}"
  end
end
