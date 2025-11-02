# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1862Solo
      class Corporation < Engine::Corporation
        def floated?
          @floated
        end

        def closed?
          @closed
        end

        def close!
          @closed = true
          @floated = false
        end

        def percent_to_float
          return 0 if @floated

          @ipo_owner.percent_of(self) - 70
        end
      end
    end
  end
end
