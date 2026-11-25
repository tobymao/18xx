# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GFrost1831
      module Step
        class ChooseInfluence < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def actions(entity)
            entity == pending&.dig(:corporation) ? ACTIONS : []
          end

          def active?
            !pending.nil?
          end

          def blocking?
            active?
          end

          def active_entities
            [pending[:corporation]]
          end

          def choice_available?(entity)
            entity == pending&.dig(:corporation)
          end

          def ipo_type(_entity)
            nil
          end

          def choice_view
            :influence_arena
          end

          def description
            'Choose Faction for Influence'
          end

          def choices
            pending[:factions].to_h { |f| [f, @game.faction_display_name(f)] }
          end

          def choice_name
            "Allocate Influence for #{pending[:corporation].name} (#{@game.influence_reason_text(pending)}) to which Faction?"
          end

          def process_choose(action)
            raise GameError, "#{action.choice} is not available" unless choices.include?(action.choice)

            @log << "#{pending[:corporation].name} allocates Influence to #{@game.faction_display_name(action.choice)}"
            @game.resolve_influence_choice!(action.choice)
          end

          private

          def pending
            @game.pending_influence_choice
          end
        end
      end
    end
  end
end
