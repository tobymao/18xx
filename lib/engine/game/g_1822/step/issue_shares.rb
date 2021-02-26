# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G1822
      module Step
        class IssueShares < Engine::Step::IssueShares
          def actions(entity)
            actions = super
            actions << 'ability_choose' unless ability_choices(entity).empty?
            actions
          end

          def ability_choices(entity)
            return {} unless entity.company?

            @game.company_choices(entity, :issue)
          end

          def process_ability_choose(action)
            @game.company_made_choice(action.entity, action.choice, :issue)
          end

          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle)
            pass!
          end
        end
      end
    end
  end
end
