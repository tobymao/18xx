# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G1860
      class Token < Token
        def actions(entity)
          return [] if entity.receivership? || @game.insolvent?(entity) || @game.sr_after_southern

          super
        end
      end
    end
  end
end
