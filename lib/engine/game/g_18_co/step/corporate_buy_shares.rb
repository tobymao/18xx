# frozen_string_literal: true

require_relative '../../../step/corporate_buy_shares'

module Engine
  module Game
    module G18CO
      module Step
        class CorporateBuyShares < Engine::Step::CorporateBuyShares
          def can_buy?(entity, bundle)
            default_can_buy = super
            return default_can_buy unless @game.optional_rules&.include?(:major_investors)
            return false unless default_can_buy

            president = entity.owner
            target = bundle.corporation
            president_percent = president.percent_of(target)
            bundle_percent = bundle.percent

            # Triggers an immediate Takeover without giving another player the presidency
            return true if entity.percent_of(target) + bundle_percent > president_percent

            # Our least concern is the current president
            # We care about players with the highest percentage
            major_share_holder, major_share_percent =
              target.player_share_holders
                .max_by { |holder, percent| [president != holder ? 1 : 0, percent] }

            # This is the case when there are no other player share holders
            return true if major_share_holder == president

            # The can be bought as long as the president wont change
            president_percent >= major_share_percent + bundle_percent
          end
        end
      end
    end
  end
end
