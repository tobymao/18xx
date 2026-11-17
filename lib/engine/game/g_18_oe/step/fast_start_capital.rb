# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18OE
      module Step
        class FastStartCapital < Engine::Step::Base
          def round_state
            super.merge(fast_start_index: 0)
          end

          def active?
            @round.fast_start_index < @round.entities.size
          end

          def blocks?
            active?
          end

          def active_entities
            return [] unless active?

            [charter]
          end

          def actions(entity)
            return [] unless active?
            return [] unless entity == charter

            ['choose']
          end

          def choice_is_amount?
            true
          end

          def choices
            [0, [limit, charter.owner.cash].min]
          end

          def choice_name
            "Extra cash for #{minor.name} (up to #{@game.format_currency(limit)})"
          end

          def description
            'Add Cash to Minors'
          end

          def process_choose(action)
            amount = action.choice.to_i
            max = choices.last
            raise GameError, "Amount must be between 0 and #{@game.format_currency(max)}" if amount.negative? || amount > max

            @game.add_fast_start_cash!(minor, amount)
            @round.fast_start_index += 1
          end

          private

          def charter
            @round.entities[@round.fast_start_index]
          end

          def minor
            @game.corporation_by_id(charter.sym)
          end

          def limit
            @game.fast_start_extra_cash_limit(minor)
          end
        end
      end
    end
  end
end
