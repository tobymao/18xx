# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G18TN
      class Dividend < Dividend
        def process_dividend(action)
          super

          abilities = action.entity.abilities(:civil_war)
          return if !abilities || abilities.empty?

          civil_war = abilities.first
          @log << "#{action.entity.name} resolves Civil War"
          civil_war.use!
        end

        def change_share_price(entity, payout)
          return super unless civil_war_effect_with_single_train?(entity)

          @log << "#{entity.name}'s share price unchanged - Civil War event, owning just one train (see rule §5.1)"
        end

        def dividend_options(entity)
          return super unless civil_war_effect_with_single_train?(entity)

          { withhold: { corporation: 0, per_share: 0, divs_to_corporation: 0 } }
        end

        def log_run_payout(entity, kind, revenue, action, payout)
          return super unless civil_war_effect_with_single_train?(entity)

          @log << "#{entity.name}'s run is ignored due to Civil War"
        end

        def dividend_types
          return super unless civil_war_effect_with_single_train?(@game.current_entity)

          [:withhold]
        end

        private

        def civil_war_effect_with_single_train?(entity)
          entity.trains.one? && entity.abilities(:civil_war)&.any?
        end
      end
    end
  end
end
