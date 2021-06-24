# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G18CO
      class SharePool < Engine::SharePool
        def presidency_check_shares(corporation)
          corporation.player_share_holders(corporate: true)
        end

        def distance(entity_a, entity_b)
          return 0 if !entity_a || !entity_b
          return @game.players.size + @game.class::MAX_SHARE_VALUE - entity_b.share_price.price if entity_b.corporation?

          super
        end
      end
    end
  end
end
