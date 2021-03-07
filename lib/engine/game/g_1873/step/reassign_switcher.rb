# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1873
      module Step
        class ReassignSwitcher < Engine::Step::Base
          BUY_ACTIONS = %w[switch_trains pass].freeze

          def actions(entity)
            return [] if entity != current_entity
            return [] unless @game.public_mine?(entity)
            return [] unless reassign_possible?(entity)

            BUY_ACTIONS
          end

          def pass_description
            @acted ? 'Done (Reassign)' : 'Skip (Reassign)'
          end

          def skip!
            return super if @game.public_mine?(current_entity)

            pass!
          end

          # don't bother with this step if all mines have the same level of switcher
          def reassign_possible?(entity)
            !@game.public_mine_mines(entity).map { |m| @game.switcher_size(m) || 0 }.uniq.one?
          end

          def description
            'Reassign Switchers'
          end

          def help_text
            'Select exactly two mines to swap switchers between'
          end

          def slot_view(entity)
            return unless @game.public_mine?(entity)

            'submines'
          end

          def process_switch_trains(action)
            entity = action.entity
            slots = action.slots

            raise GameError, 'Exactly 2 mines must be selected' if slots.size != 2
            raise GameError, 'Illegal slot' if slots.max >= @game.public_mine_mines(entity).size
            raise GameError, 'Illegal slot' if slots.min.negative?

            @game.swap_switchers(entity, slots)
          end
        end
      end
    end
  end
end
