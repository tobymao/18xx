# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18Rhl
      module Round
        class Operating < Engine::Round::Operating
          attr_accessor :teleport_ability

          def next_entity!
            # Just in case Trajektanstalt made a teleport for this entity, complete it.
            @game.complete_trajektanstalt_teleport

            super
          end
        end
      end
    end
  end
end
