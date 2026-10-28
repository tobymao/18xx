# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 4.2: a company that lays no tile during its Operating Round may take one free
        # Upgrade License, valid only in its next Operating Round. A company holds at most one.
        class UpgradeLicense < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def description
            'Upgrade License'
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.corporation?
            return [] unless @round.laid_hexes.empty?
            return [] if @game.upgrade_license?(entity)

            ACTIONS
          end

          def log_skip(_entity); end

          def choice_name
            'Upgrade License'
          end

          def choices
            { 'license' => 'Get an Upgrade License (free; only valid in the next Operating Round)' }
          end

          def process_choose(action)
            entity = action.entity
            @game.grant_upgrade_license!(entity)
            @log << "#{entity.name} gets an Upgrade License for the next Operating Round"
            pass!
          end
        end
      end
    end
  end
end
