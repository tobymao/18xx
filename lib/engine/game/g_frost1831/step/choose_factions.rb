# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GFrost1831
      module Step
        class ChooseFactions < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def actions(entity)
            return [] unless entity == pending_choice&.dig(:entity)

            ACTIONS
          end

          def choice_available?(entity)
            entity == pending_choice&.dig(:entity)
          end

          def active?
            !pending_choice.nil?
          end

          def blocking?
            active?
          end

          def active_entities
            [pending_choice[:entity]]
          end

          def ipo_type(_entity)
            nil
          end

          def choice_views
            [['GFrost1831::InfluenceArena', { game: @game, scale: 0.67 }]]
          end

          def description
            'Choose Faction to Support'
          end

          def choices
            available = available_factions
            @game.faction_order.select { |f| available.include?(f) }.to_h do |f|
              [f, "#{@game.faction_display_name(f)} (#{@game.faction_support_remaining(f)})"]
            end
          end

          def choice_name
            corporation = pending_choice[:corporation]
            first? ? "Choose faction to support for #{corporation.name}" : "Choose 2nd faction to support for #{corporation.name}"
          end

          def process_choose(action)
            faction = action.choice
            raise GameError, "#{faction} is not available" unless choices.include?(faction)

            corporation = pending_choice[:corporation]
            @log << "#{action.entity.name} chooses #{@game.faction_display_name(faction)} as "\
                    "#{first? ? '1st' : '2nd'} faction for #{corporation.name}"
            @game.consume_faction_support!(faction)
            @game.apply_faction_influence!(corporation, faction)

            if first?
              @game.choose_first_faction!(faction)
            else
              @game.finish_faction_choice!(faction)
            end
          end

          private

          def first?
            pending_choice[:step] == :first
          end

          def available_factions
            return @game.faction_support_available if first?

            available = @game.faction_support_available_for_second(pending_choice[:first_choice])
            return available unless @game.parliamentary_intervention?

            corporation = pending_choice[:corporation]
            others = @game.corporations.select do |c|
              c.type != :faction && c.owner == corporation.owner && c.floated? && c != corporation
            end
            return available unless others.size == 1

            supported = @game.corporation_factions(others.first)
            return available unless supported.include?(pending_choice[:first_choice])

            different = available - supported
            different.empty? ? available : different
          end

          def pending_choice
            @game.pending_faction_choice
          end
        end
      end
    end
  end
end
