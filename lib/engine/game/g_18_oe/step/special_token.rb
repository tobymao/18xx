# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18OE
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def process_place_token(action)
            super
            @game.remove_wcf_placeholder! if action.entity.id == 'WCF'
          end
        end
      end
    end
  end
end
