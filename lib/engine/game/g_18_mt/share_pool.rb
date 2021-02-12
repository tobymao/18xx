# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G18MT
      class SharePool < Engine::SharePool
        def presidency_check_shares(corporation)
          corporation.player_share_holders(corporate: true)
        end

        def shares_for_presidency_swap(shares, num_shares)
          return [] if shares.empty?
          return [] unless num_shares
          return shares if shares.one?

          percent = num_shares * shares.first.corporation.share_percent
          matching_bundles = (1..shares.size).flat_map do |n|
            shares.combination(n).to_a.select { |b| b.sum(&:percent) == percent }
          end

          # we want the bundle with the most shares, as higher percent in fewer shares is more valuable
          matching_bundles.max_by(&:size)
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
