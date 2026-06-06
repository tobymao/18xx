# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1862UsaCanada
      module Step
        class Dividend < Engine::Step::Dividend
          def process_dividend(action)
            entity = action.entity
            first_time = entity.operating_history.none? { |_, info| info.dividend.kind.to_sym == :payout }
            @game.activate_new_bonuses!(entity, routes)
            @game.check_golden_spike!(entity, routes)
            super
            @game.on_first_payout!(entity) if first_time && action.kind.to_sym == :payout
          end

          # Non-buyable treasury shares (the 50% buyback cert) earn dividends back
          # into the corporation.  For corps that have never done a buyback, the
          # non-buyable set is empty and this reduces to super.
          def corporation_dividends(entity, per_share)
            treasury_units = entity.shares_of(entity)
                                   .reject(&:buyable)
                                   .sum { |s| s.num_shares(ceil: false) }
            super + (treasury_units * per_share).ceil
          end
        end
      end
    end
  end
end
