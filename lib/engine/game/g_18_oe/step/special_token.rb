# frozen_string_literal: true

require_relative '../../../step/special_token'
require_relative 'skip_abbreviated_round'

module Engine
  module Game
    module G18OE
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          include SkipAbbreviatedRound

          def process_place_token(action)
            super
            @game.remove_wcf_placeholder! if action.entity.id == 'WCF'
          end
        end
      end
    end
  end
end
