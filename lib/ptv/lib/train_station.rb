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
class TrainStation < TransitStop
  def initialize(attributes = {})
    super
    @route_type = @route_types[self.class.name.downcase.to_sym]
    # @number = attributes[:number]
    # @stop = find_stop(@number, attributes[:stop])
    # @routes = find_routes(@number)
  end
end
