# frozen_string_literal: true

###########################################################
#                                                         #
#   HASH MAP                                              #
#                                                         #
###########################################################
#                                                         #
#   Takes a list of departures and builds a hash map.     #
#                                                         #
#   Groups departures by the same run_ref and route_id,   #
#   allowing for quicker lookups based on these keys.     #
#                                                         #
###########################################################
class HashMap
  def self.group_by_run_ref_and_route_id(departures)
    departures.each_with_object({}) do |departure, hash|
      key = [departure[:run_ref], departure[:route_id]]
      hash[key] ||= []
      value = hash[key]
      value << departure
    end
  end
end
#########################################################
#                                                       #
#   Example Usage                                       #
#                                                       #
#########################################################
#
#   departures = [
#     { run_ref: 'A1', route_id: 1, other_info: 'info1' },
#     { run_ref: 'A1', route_id: 1, other_info: 'info2' },
#     { run_ref: 'B2', route_id: 2, other_info: 'info3' }
#   ]
#
#   HashMap.group_by_run_ref_and_route_id(departures)
#   # =>
#
#    {
#      ['A1', 1] => [
#        { run_ref: 'A1', route_id: 1, other_info: 'info1' },
#        { run_ref: 'A1', route_id: 1, other_info: 'info2' }
#      ],
#
#      ['B2', 2] => [
#        { run_ref: 'B2', route_id: 2, other_info: 'info3' }
#      ]
#    }
#
#########################################################
