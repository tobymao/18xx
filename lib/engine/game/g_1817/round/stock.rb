# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1817
      module Round
        class Stock < Engine::Round::Stock
          def finish_round
            super
            @game.corporations.select(&:floated?).each do |corp|
              if tokens_needed?(corp)
                @log << "#{corp.name} did not purchase tokens and liquidates"
                @game.liquidate!(corp)
              end
            end

            # This is done here, as the tokens need to be checked before closing the train station
            train_station = @game.company_by_id(@game.class::TRAIN_STATION_PRIVATE_NAME)
            train_station.close! if train_station&.owner&.corporation?
          end

          def tokens_needed?(corporation)
            !corporation.operated? && @game.tokens_needed(corporation).positive?
          end

          def sold_out_stock_movement(corp)
            @game.stock_market.move_up(corp)
            return unless @game.option_short_squeeze?

            @game.stock_market.move_up(corp) if corp.player_share_holders.values.select(&:positive?).sum > 100
          end

          def sold_out?(corporation)
            corporation.total_shares > 2 && corporation.player_share_holders.values.select(&:positive?).sum >= 100
          end
        end
      end
    end
  end
end
