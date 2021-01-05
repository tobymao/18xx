# frozen_string_literal: true

require_relative '../operating'
require_relative '../../step/buy_train'

module Engine
  module Round
    module G18SJ
      class Operating < Operating
        def next_entity!
          @game.clean_up_after_entity
          super
        end

        def cash_crisis_player
          @game.cash_crisis_player
        end
      end
    end
  end
end
