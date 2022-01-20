# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G18Scan
      class Corporation < Engine::Corporation
        def floatable?
          super && @game.sj && @game.phase.status.include?('sj_unavailable')
        end
      end
    end
  end
end
