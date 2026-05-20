# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G18OE
      module Step
        class Consolidate < G18OE::Step::BuySellParShares
          CONVERT_ACTIONS = ['convert'].freeze

          def actions(entity)
            return [] if pending_corps(entity).empty?

            regional_convertible?(entity) ? CONVERT_ACTIONS : []
          end

          def description
            'Consolidate or abandon minors/regionals'
          end

          def blocks?
            !pending_corps(current_entity).empty?
          end

          def regional_convertible?(entity)
            pending_corps(entity).any? { |corp| can_convert?(corp) }
          end

          def can_convert?(entity)
            return false unless entity.type == :regional
            return false if @converted

            true
          end

          def process_convert(action)
            super
            pass!
          end

          private

          def pending_corps(entity)
            @game.corporations.select { |c| c.type == :regional && c.president?(entity) }
          end
        end
      end
    end
  end
end
