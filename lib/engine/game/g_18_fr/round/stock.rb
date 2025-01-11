# frozen_string_literal: true

require_relative '../../g_1817/round/stock'

module Engine
  module Game
    module G18FR
      module Round
        class Stock < G1817::Round::Stock
          def finish_round
            super

            @game.players.each do |player|
              if player.shares.any? { |s| s.percent.negative? }
                @game.player_sr_with_short_count[player] += 1
                @log << "#{player.name} has their certificate limit permanently increased by 1 for owning a short share"
              end
            end
          end

          def finish_round
            # Do not move stock prices after Stock Round, they'll move after Share Redemption Round
          end
        end
      end
    end
  end
end
