# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1866
      class SharePool < Engine::SharePool
        def fit_in_bank?(bundle)
          return super unless @game.major_national_corporation?(bundle.corporation)

          (bundle.percent + percent_of(bundle.corporation)) <= @game.class::NATIONAL_MARKET_SHARE_LIMIT
        end

        def bank_at_limit?(corporation)
          return super unless @game.major_national_corporation?(corporation)

          percent_of(corporation) >= @game.class::NATIONAL_MARKET_SHARE_LIMIT
        end

        def distance(player_a, player_b)
          return 0 if !player_a || !player_b

          # Find the correct player according to stock turn token operational order
          after_index = @game.round.entity_index + 1
          after = if after_index < @game.round.entities.size
                    @game.round.entities[after_index..-1].select { |c| @game.stock_turn_corporation?(c) }
                  else
                    []
                  end

          before_index = @game.round.entity_index - 1
          before = if before_index.positive?
                     @game.round.entities[0..before_index].select { |c| @game.stock_turn_corporation?(c) }
                   else
                     []
                   end

          found_players = Hash.new { |h, k| h[k] = false }
          index = 1
          (after + before).each do |c|
            player = c.owner
            return index if player == player_b

            index += 1 if !found_players[player] && player != player_a
            found_players[player] = true
          end

          # We couldnt find any stock turn tokens, use standard player order to determine distance.
          super
        end
      end
    end
  end
end
