# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GFrost1831
      module Step
        class Intervention < Engine::Step::Base
          def actions(entity)
            return [] unless entity == corporation

            %w[choose]
          end

          def active?
            !@game.intervention.nil?
          end

          def blocking?
            active?
          end

          def active_entities
            [corporation]
          end

          def description
            "Intervention in #{corporation.name}"
          end

          def help
            [
              "#{corporation.full_name} is being intervened.",
              instruction,
            ]
          end

          def ipo_type(_entity)
            nil
          end

          def available_hex(_entity, hex)
            !hex_choices(hex).empty?
          end

          def choice_available?(entity)
            entity == corporation
          end

          def choice_name; end

          def choices
            {}
          end

          def hex_choices(hex)
            @game.intervention_choices.select { |_, (token, _)| token.city.hex == hex }.transform_values(&:last)
          end

          def choice_view
            :intervention_choice
          end

          def process_choose(action)
            token, faction = @game.intervention_choices[action.choice]
            raise GameError, "#{action.choice} is not a possible replacement" unless token

            @game.replace_station!(token, faction)
          end

          private

          def corporation
            @game.intervention&.dig(:corporation)
          end

          def instruction
            replacements = @game.intervention_choices.values
            factions = replacements.map(&:last).uniq
            names = factions.map(&:full_name).join(' and ')
            return "Choose a station to give to #{names}." if factions.one?
            return "Choose which faction between #{names} receives the station." if replacements.map(&:first).uniq.one?

            "Choose stations to distribute between #{names}."
          end
        end
      end
    end
  end
end
