# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18FR
      module Round
        class ShareRedemption < Engine::Round::Stock
          attr_writer :loan_taken, :share_redeemed

          def self.short_name
            'SRR'
          end

          def self.round_name
            'Share Redemption Round'
          end

          def setup
            @loan_taken = false
            @share_redeemed = false
          end

          def select_entities
            corporations = @game.corporations.select do |corp|
              corp.floated? && !corp.share_price.acquisition? && !@game.share_pool.shares_of(corp).empty?
            end

            if corporations.empty?
              @log << 'No corporation can redeem shares'
              finish_round
            end

            corporations.sort
          end

          def next_entity!
            raise GameError, 'Must redeem share if loan taken' if @loan_taken && !@share_redeemed

            @entities[@entity_index].pass!

            @loan_taken = false
            @share_redeemed = false

            next_entity_index! unless @entities.empty?

            @steps.each(&:unpass!)
            @steps.each(&:setup)

            skip_steps

            finish_round if finished?
          end

          def sold_out_stock_movement(corp)
            @game.stock_market.move_up(corp)
            return unless @game.option_short_squeeze?

            @game.stock_market.move_up(corp) if corp.player_share_holders.values.select(&:positive?).sum > 100
          end

          def sold_out?(corporation)
            corporation.total_shares > 2 && corporation.player_share_holders.values.select(&:positive?).sum >= 100
          end

          def show_in_history?
            false
          end
        end
      end
    end
  end
end
