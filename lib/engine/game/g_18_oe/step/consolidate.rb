# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G18OE
      module Step
        class Consolidate < G18OE::Step::BuySellParShares
          def actions(entity)
            return [] unless entity == current_entity
            return [] if pending_corps(entity).empty?

            can_convert_any? ? ['convert'] : []
          end

          def description
            'Consolidate or abandon minors/regionals'
          end

          def blocks?
            !pending_corps(current_entity).empty?
          end

          def can_convert?(entity)
            return false unless entity.type == :regional
            return false if @converted
            return false unless entity.president?(current_entity)

            true
          end

          def process_convert(action)
            super
            pass!
          end

          private

          def pending_corps(entity)
            @game.corporations.select { |c| %i[minor regional].include?(c.type) && c.president?(entity) }
          end
        end
      end
    end
  end
end
