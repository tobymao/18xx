# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18MT
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_buy_any?(entity)
            return true if can_buy_any_corporate?(entity)

            super
          end

          def can_buy_any_corporate?(entity)
            !bought? && @game.corporations.any? do |c|
              can_buy?(entity, c.corporate_shares.first&.to_bundle)
            end
          end

          def can_buy?(entity, bundle)
            if bundle&.owner&.corporation? &&
                bundle.corporation != bundle.owner &&
                !bundle.owner.president?(entity) &&
                !@game.phase.status.include?('corporate_shares_open')
              return false
            end

            super
          end

          def can_sell?(entity, bundle)
            return false unless super
            return false if last_acted_upon?(bundle.corporation, entity)
            return true unless entity == bundle.corporation.owner

            major_share_holder, major_share_percent =
              bundle.corporation.share_holders
                .max_by { |holder, percent| [entity != holder ? 1 : 0, percent, holder.player? ? 1 : 0] }

            return true if major_share_holder == entity
            return true unless major_share_holder.corporation?
            return true if major_share_holder == bundle.corporation

            major_share_percent <= entity.percent_of(bundle.corporation) - bundle.percent
          end
        end
      end
    end
  end
end
