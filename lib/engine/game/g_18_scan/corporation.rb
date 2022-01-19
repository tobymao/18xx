# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G18Scan
      class Corporation < Engine::Corporation
        def floatable?
          super && @game.sj && @game.phase.status.include?('sj_unavailable')
        end

        def floated?
          return false unless @floatable

          @floated ||= @ipo_owner.percent_of(self) <= 100 - @game.float_percent
        end
      end
    end
  end
end
