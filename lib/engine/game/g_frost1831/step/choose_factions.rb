# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GFrost1831
      module Step
        class ChooseFactions < Engine::Step::Base
          # After a corporation floats, the president must choose 2 factions to support.
          # This step activates when there's a pending faction choice.

          ACTIONS = %w[choose].freeze

          def actions(entity)
            return [] unless pending_choice
            return [] unless entity == pending_choice[:entity]

            ACTIONS
          end

          def choice_available?(entity)
            return false unless pending_choice

            entity == pending_choice[:entity]
          end

          def active?
            !!pending_choice
          end

          def blocking?
            !!pending_choice
          end

          def active_entities
            return [] unless pending_choice

            [pending_choice[:entity]]
          end

          def ipo_type(_entity)
            nil
          end

          def description
            'Choose Faction to Support'
          end

          # Panels shown below the choice buttons: the influence arena (mini).
          def extra_choice_components
            [[View::Game::GFrost1831::InfluenceArena, { game: @game, scale: 0.67 }]]
          end

          # Tell the view to use faction icons instead of text buttons
          def use_faction_icons?
            true
          end

          FACTION_ORDER = %w[TEC LOR GUA EXP].freeze

          def choices
            available = if pending_choice[:step] == :first
                          @game.faction_support_available
                        else
                          available_for_second
                        end

            FACTION_ORDER.select { |f| available.include?(f) }.map do |f|
              slots = @game.faction_support_remaining(f)
              [f, "#{faction_name(f)} (#{slots})"]
            end.to_h
          end

          def choice_name
            corp = pending_choice[:corporation]
            available = if pending_choice[:step] == :first
                          @game.faction_support_available
                        else
                          available_for_second
                        end

            unavailable = FACTION_ORDER.reject { |f| available.include?(f) }
            unavailable_text = if !unavailable.empty?
                                 parts = unavailable.map { |f| "#{faction_name(f)} (#{@game.faction_support_remaining(f)})" }
                                 " - #{parts.join(' and ')} not available"
                               else
                                 ''
                               end

            if pending_choice[:step] == :first
              "Choose faction to support for #{corp.name}#{unavailable_text}"
            else
              "Choose 2nd faction to support for #{corp.name}#{unavailable_text}"
            end
          end

          def process_choose(action)
            choice = action.choice
            corp = pending_choice[:corporation]
            entity = pending_choice[:entity]

            if pending_choice[:step] == :first
              @game.consume_faction_support(choice)
              @log << "#{entity.name} chooses #{faction_name(choice)} as 1st faction for #{corp.name}"

              # Apply cube and move government immediately for 1st choice
              @game.apply_faction_influence(corp, choice)

              # Store first choice before checking available_for_second
              @game.pending_faction_choices.last[:step] = :second
              @game.pending_faction_choices.last[:first_choice] = choice

              # Legacy games auto-pick the 2nd faction when only one option is
              # left. New games always ask the player, since the silent
              # auto-pick (which can also pass the turn) confused players.
              available_second = available_for_second
              if @game.auto_second_faction? && available_second.size == 1
                # Automatic second choice
                second = available_second.first
                @game.consume_faction_support(second)
                @log << "#{entity.name} automatically chooses #{faction_name(second)} as 2nd faction for #{corp.name}"
                @game.apply_faction_influence(corp, second)
                complete_faction_choice(corp, [choice, second])
              end
              # else: Need second choice from player (step/first_choice already set)
            else
              # Second choice
              @game.consume_faction_support(choice)
              first = pending_choice[:first_choice]
              @log << "#{entity.name} chooses #{faction_name(choice)} as 2nd faction for #{corp.name}"

              # Apply cube and move government for 2nd choice
              @game.apply_faction_influence(corp, choice)
              complete_faction_choice(corp, [first, choice])
            end
          end

          private

          def available_for_second
            base = @game.faction_support_available_for_second(pending_choice[:first_choice])

            # Parliamentary Intervention: if this is the player's 2nd corporation,
            # must support at least 1 faction different from 1st corp's factions
            if @game.parliamentary_intervention?
              entity = pending_choice[:entity]
              corp = pending_choice[:corporation]
              player_corps = @game.corporations.select { |c| c.type != :faction && c.owner == entity && c.floated? && c != corp }

              if player_corps.size == 1
                first_corp = player_corps.first
                first_corp_factions = @game.corporation_factions(first_corp)
                different = base.reject { |f| first_corp_factions.include?(f) }
                # Only restrict if there are different options available
                base = different unless different.empty?
              end
            end

            base
          end

          def pending_choice
            @game.pending_faction_choices&.first
          end

          def complete_faction_choice(corporation, factions)
            @game.on_corporation_floated(corporation, factions)
            @game.pending_faction_choices.shift
          end

          def faction_name(sym)
            case sym
            when 'TEC' then 'Technicians'
            when 'GUA' then 'Guardians'
            when 'EXP' then 'Expansionists'
            when 'LOR' then 'Lords'
            else sym
            end
          end
        end
      end
    end
  end
end
