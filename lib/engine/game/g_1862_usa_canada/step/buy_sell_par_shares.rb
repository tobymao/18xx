# frozen_string_literal: true

module Engine
  module Game
    module G1862UsaCanada
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          # Restrict NYH par to exactly $100 while NHSC is open and unparred
          def get_par_prices(entity, corp)
            prices = super
            nhsc = @game.company_by_id('NHSC')
            return prices if corp&.id != 'NYH' || !nhsc || nhsc.closed?

            prices.select { |p| p.price == 100 }
          end

          def can_sell?(entity, bundle)
            corp = bundle&.corporation
            return false if corp && entity == corp.owner && @game.bond?(corp)
            return false if corp && entity == corp.owner && corp.trains.empty?

            super
          end

          def process_buy_shares(action)
            super
            collect_monopoly_fee(action.entity, action.bundle)
          end

          private

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
            @game.log << "#{player.name} pays $#{fee} monopoly fee " \
                         "(#{held_pct}% of #{corporation.name} exceeds #{threshold}%)"
          end
        end
      end
    end
  end
end
