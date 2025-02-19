# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/ptv/helpers/hash_map'

RSpec.describe HashMap do
  describe '.group_by_run_ref_and_route_id' do
    let(:departures) do
      [
        { run_ref: 'A1', route_id: 1, other_info: 'info1' },
        { run_ref: 'A1', route_id: 1, other_info: 'info2' },
        { run_ref: 'B2', route_id: 2, other_info: 'info3' }
      ]
    end

    it 'groups departures by run_ref and route_id' do
      result = HashMap.group_by_run_ref_and_route_id(departures)
      expected_result = {
        ['A1', 1] => [
          { run_ref: 'A1', route_id: 1, other_info: 'info1' },
          { run_ref: 'A1', route_id: 1, other_info: 'info2' }
        ],
        ['B2', 2] => [
          { run_ref: 'B2', route_id: 2, other_info: 'info3' }
        ]
      }
      expect(result).to eq(expected_result)
    end

    it 'returns an empty hash for an empty list' do
      result = HashMap.group_by_run_ref_and_route_id([])
      expect(result).to eq({})
    end

    it 'handles departures with unique run_ref and route_id combinations' do
      unique_departures = [
        { run_ref: 'A1', route_id: 1, other_info: 'info1' },
        { run_ref: 'B2', route_id: 2, other_info: 'info2' },
        { run_ref: 'C3', route_id: 3, other_info: 'info3' }
      ]
      result = HashMap.group_by_run_ref_and_route_id(unique_departures)
      expected_result = {
        ['A1', 1] => [{ run_ref: 'A1', route_id: 1, other_info: 'info1' }],
        ['B2', 2] => [{ run_ref: 'B2', route_id: 2, other_info: 'info2' }],
        ['C3', 3] => [{ run_ref: 'C3', route_id: 3, other_info: 'info3' }]
      }
      expect(result).to eq(expected_result)
    end

    it 'handles departures with missing run_ref or route_id' do
      incomplete_departures = [
        { run_ref: nil, route_id: 1, other_info: 'info1' },
        { run_ref: 'A1', route_id: nil, other_info: 'info2' },
        { run_ref: nil, route_id: nil, other_info: 'info3' }
      ]
      result = HashMap.group_by_run_ref_and_route_id(incomplete_departures)
      expected_result = {
        [nil, 1] => [{ run_ref: nil, route_id: 1, other_info: 'info1' }],
        ['A1', nil] => [{ run_ref: 'A1', route_id: nil, other_info: 'info2' }],
        [nil, nil] => [{ run_ref: nil, route_id: nil, other_info: 'info3' }]
      }
      expect(result).to eq(expected_result)
    end

    it 'handles a large list of departures' do
      large_departures = 1000.times.map do |i|
        { run_ref: "A#{i % 10}", route_id: i % 10, other_info: "info#{i}" }
      end
      result = HashMap.group_by_run_ref_and_route_id(large_departures)
      expect(result.keys.size).to eq(10)
      expect(result[['A0', 0]].size).to eq(100)
    end
  end
end
