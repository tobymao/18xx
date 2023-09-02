# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1847AE
      module Round
        class Operating < Engine::Round::Operating
          def setup
            @game.train_bought_this_round = false

            super
          end
        end
      end
    end
  end
end
