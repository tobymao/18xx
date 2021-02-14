# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18EU
      class Track < Track
        include Tracker

        def process_lay_tile(action)
          # TODO: Mountain to Rough change

          super
        end
      end
    end
  end
end
