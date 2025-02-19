# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/ptv/timetable'

RSpec.describe Timetable do
  let(:timetable) { Timetable.new }

  describe '#get_all_future_tram_departures_from' do
    let(:stop) { { route_type: 1, stop_id: 123 } }

    context 'when there are future departures' do
      it 'returns only future departures' do
        future_departure = { scheduled_departure_utc: (Time.now + 3600).utc.iso8601 }
        past_departure = { scheduled_departure_utc: (Time.now - 3600).utc.iso8601 }

        allow(timetable).to receive(:get_departures_from).with(stop).and_return([future_departure, past_departure])

        result = timetable.get_all_future_tram_departures_from(stop)
        expect(result).to eq([future_departure])
      end
    end

    context 'when an error occurs' do
      it 'raises a ResponseError' do
        allow(timetable).to receive(:get_departures_from).with(stop).and_raise(StandardError)

        expect { timetable.get_all_future_tram_departures_from(stop) }.to raise_error(ResponseError)
      end
    end
  end

  describe '#find_tram_stop' do
    let(:attributes) { { stop_number: 37, tram_number: 5 } }

    context 'when the tram stop is found' do
      it 'returns the correct tram stop' do
        tram_route = { route_id: 1, route_type: 1 }
        stop = { stop_name: '#37', stop_id: 123 }

        allow(timetable).to receive(:find_tram_route).with(attributes[:tram_number]).and_return(tram_route)
        allow(timetable).to receive(:get_all_stops_for).with(tram_route).and_return([stop])

        result = timetable.find_tram_stop(attributes)
        expect(result).to eq(stop)
      end
    end

    context 'when an error occurs' do
      it 'raises a ResponseError' do
        allow(timetable).to receive(:find_tram_route).and_raise(StandardError)

        expect { timetable.find_tram_stop(attributes) }.to raise_error(ResponseError)
      end
    end
  end
end
