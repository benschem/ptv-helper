# frozen_string_literal: true

require 'sinatra'
require_relative 'config/environment'
# require 'debug'
#
#
#
################################# TODO: NEED TO SCRAPE TROM STOP SITE FIRST AS API DATA IS NOT REAL TIME

get '/' do
  # Get future departures for the rest of the day for city bound trams from the Landsdowne Rd stop
  begin
    # tram = params[:tram]
    # stop = params[:stop]
    # tram_stop_id = Tram.find_stop(tram, stop)
    tram_stop_id = 1107
    @tram_arrival_times = TramStop.new(tram_stop_id).next_arrivals

    # IDEA: USE API TO CALC AVG TIME BETWEEN STOPS

    # timetable = Timetable.new
    # lansdowne_rd = timetable.find_tram_stop(stop_number: 37, tram_number: 5)
    # departures_from_lansdown = timetable.get_all_future_tram_departures_from(lansdowne_rd)
    # chapel_st = timetable.find_tram_stop(stop_number: 32, tram_number: 5)
    # departures_from_chapel_st = timetable.get_all_future_tram_departures_from(chapel_st)
    # @matched_trams = timetable.find_matching_arrivals(departures_from_lansdown, departures_from_chapel_st)
  rescue ResponseError => e
    @error = e
  end

  # Get departure time for next city bound train from Windsor station after arrival at last tram stop
  begin
    #   # Fetch Windsor Station
    #   # Fetch departures from the station on the correct route and direction
    #   # Filter to departures closest to arrival at last tram stop
  rescue ResponseError => e
    @error = e
  end

  # Get arrival time for each of those trains at Richmond station
  begin
    #   # Find Richmond Station
    #   # Get departures from the station
    #   # Filter to departures on the same run after the arrival time
  rescue ResponseError => e
    @error = e
  end

  erb :index
end
