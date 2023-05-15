# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1880
      class Corporation < Engine::Corporation
        attr_accessor :building_permits, :fully_funded

        def floated?
          @floated
        end

        def float!
          @floated = true
        end

        def percent_to_float
          return 0 if @floated

          [[@float_percent - (owner&.percent_of(self) || 0), 0].max, @ipo_owner.percent_of(self)].min
        end
      end
    end
  end
end
