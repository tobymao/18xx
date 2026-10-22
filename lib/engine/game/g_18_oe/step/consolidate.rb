# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G18OE
      module Step
        class Consolidate < G18OE::Step::BuySellParShares
          def description
            'Consolidate regionals into majors'
          end

          def actions(entity)
            actions = super
            return actions if entity.corporation? || @converting || @converted || !presides_regional?(entity)

            actions - ['pass']
          end

          private

          def presides_regional?(player)
            @game.corporations.any? { |c| c.type == :regional && c.president?(player) }
          end
        end
      end
    end
  end
end
