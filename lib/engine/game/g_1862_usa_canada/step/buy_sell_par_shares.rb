# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1862UsaCanada
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          # NHSC gives the buyer NYH's director cert; NYH must be parred at
          # exactly $100. Restrict available par prices to that single value.
          def get_par_prices(entity, corporation)
            return nyh_par_prices if corporation.id == 'NYH'

            super
          end

          # Director of a corporation with an active bond may not sell its shares.
          def can_sell?(entity, bundle)
            return false if director_bond_blocks_sale?(entity, bundle)

            super
          end

          def process_buy_shares(action)
            super
            collect_monopoly_fee(action.entity, action.bundle)
          end

          private

          def nyh_par_prices
            [@game.stock_market.par_prices.find { |p| p.price == 100 }].compact
          end

          def director_bond_blocks_sale?(entity, bundle)
            return false unless bundle

            bundle.corporation.president?(entity) && @game.bond?(bundle.corporation)
          end

          def collect_monopoly_fee(player, bundle)
            corporation = bundle.corporation
            held_pct    = player.percent_of(corporation)
            threshold   = @game.monopoly_threshold
            return unless held_pct > threshold

            prev_pct    = held_pct - bundle.percent
            over_now    = [held_pct - threshold, 0].max / 10
            over_before = [prev_pct - threshold, 0].max / 10
            newly_over  = [over_now - over_before, 0].max
            return if newly_over.zero?

            fee = newly_over * @game.monopoly_fee(bundle.shares.first)
            return if fee.zero?

            player.spend(fee, @game.bank)
            @game.log << "#{player.name} pays #{@game.format_currency(fee)} monopoly fee " \
                         "(#{held_pct}% of #{corporation.name} exceeds #{threshold}%)"
          end
        end
      end
    end
  end
end
