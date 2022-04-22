# frozen_string_literal: true

require_relative '../../g_1817/round/stock'

module Engine
  module Game
    module G18USA
      module Round
        class Stock < G1817::Round::Stock
          def finish_round
            @game.corporations.select(&:floated?).sort.each do |corp|
              prev = corp.share_price.price
              sold_out_stock_movement(corp) if sold_out?(corp) && @game.sold_out_increase?(corp)
              shares_in_pool = corp.num_market_shares
              price_drops = shares_in_pool * 2
              price_drops.times { @game.stock_market.move_down(corp) }
              @game.log_share_price(corp, prev)
            end
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

          def setup
            @buy_sell_par_shares_step = @steps.find { |step| step.class.to_s.include?('BuySellParShares') }
            super
          end

          def after_process_before_skip(action)
            @buy_sell_par_shares_step.after_process_before_skip(action)
          end
        end
      end
    end
  end
end
