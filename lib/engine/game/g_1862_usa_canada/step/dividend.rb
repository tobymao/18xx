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
            super
            @game.on_first_payout!(entity) if first_time && action.kind.to_sym == :payout
          end
        end
      end
    end
  end
end
