# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1880Romania
      class Corporation < Engine::Corporation
        attr_accessor :building_permits, :fully_funded

        def floated?
          @floated ||= @ipo_owner.percent_of(self) <= (100 - @float_percent)
        end

        def percent_to_float
          return 0 if @floated

          @ipo_owner.percent_of(self) - (100 - @float_percent)
        end

        def float!
          @floated = true
        end
      end
    end
  end
end
