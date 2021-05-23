# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'choose_ability_on_or'
require_relative 'tracker'

module Engine
  module Game
    module G18ZOO
      module Step
        class Track < Engine::Step::Track
          include Engine::Game::G18ZOO::ChooseAbilityOnOr
          include Engine::Game::G18ZOO::Step::Tracker

          def available_hex(entity, hex)
            return false if %w[M MM].include?(hex.location_name) && hex.tile.color != :white
            return false if hex.tile.label.to_s == 'O' && hex.tile.color != :white
            return false if %i[red gray].include?(hex.tile.color)

            super
          end

          def potential_tiles(_entity, hex)
            super
              .reject { |tile| %w[80 X80 81 X81 82 X82 83 X83].include?(tile.name) }
          end

          def help
            @game.threshold_help
          end
        end
      end
    end
  end
end
