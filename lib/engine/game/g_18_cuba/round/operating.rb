# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18Cuba
      module Round
        class Operating < Engine::Round::Operating
          def next_entity!
            @game.pay_fc_for_unshipped_cubes if @entity_index == @entities.size - 1
            super
          end
        end
      end
    end
  end
end
