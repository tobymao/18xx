# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18FR
      module Round
        class ShareRedemption < Engine::Round::Stock
          def self.short_name
            'SRR'
          end

          def self.round_name
            'Share Redemption Round'
          end

          def setup
            @finished = false
          end

          def select_entities
            corporations = @game.corporations.select { |c| c.floated? && !c.share_price.acquisition? && @game.share_pool.shares_of(c).any? }

            if corporations.empty?
              @log << "No corporation can redeem shares"
              finish_round
            end

            corporations.sort
          end

          def next_entity!
            return finish_round if finished?

            @entities.delete_at(@entity_index)
          end

          def finished?
            @game.finished || @entities.empty?

            def sold_out_stock_movement(corp)
              @game.stock_market.move_up(corp)
              return unless @game.option_short_squeeze?

              @game.stock_market.move_up(corp) if corp.player_share_holders.values.select(&:positive?).sum > 100
            end

            def sold_out?(corporation)
              corporation.total_shares > 2 && corporation.player_share_holders.values.select(&:positive?).sum >= 100
            end
          end

          def show_in_history?
            false
          end
        end
      end
    end
  end
end
