# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G18GB
      module Step
        class EMRShareBuying < G18GB::Step::BuySellParShares
          def actions(entity)
            return [] unless entity == current_entity
            return [] unless @round.emergency_converted
            return [] unless can_buy_any?(entity)

            %w[buy_shares pass]
          end

          def active_entities
            return [] unless @round.emergency_converted

            [entities[entity_index].owner]
          end

          def can_buy?(entity, bundle)
            return false unless bundle&.corporation == @round.current_operator

            super
          end

          def can_sell_any?
            false
          end

          def can_sell?(_entity, _bundle)
            false
          end

          def description
            'Optionally buy a share after conversion'
          end
        end
      end
    end
  end
end
