# frozen_string_literal: true

require_relative '../../../step/token'
require_relative 'connection'

module Engine
  module Game
    module G1870
      module Step
        class ConnectionToken < Engine::Step::Token
          include Connection

          def actions(_entity)
            %w[choose]
          end

          def description
            'Return Connection Token'
          end

          def choice_name
            'Use of destination token'
          end

          def choices
            destination = @round.connection_runs[current_entity]
            return %w[Map Charter] unless destination.tile.cities.any? { |c| c.tokened_by?(current_entity) }

            ['Charter']
          end

          def process_choose(action)
            entity = action.entity
            destination = @round.connection_runs[entity]
            ability = entity.abilities.first

            token = Engine::Token.new(action.entity, price: 100)
            action.entity.tokens << token
            destination.remove_assignment!(entity)

            if action.choice == 'Map'
              destination.tile.cities.first.place_token(entity, token, free: true, extra_slot: true)
              @game.graph.clear
              ability.description = 'Reached ' + ability.description

              @log << "#{entity.name} places destination token on the map with bonus"
            else
              entity.remove_ability(ability)

              @log << "#{entity.name} puts destination token on the charter for later use, forfeiting the bonus"
            end

            entity.trains.each { |train| train.operated = false }

            pass!
          end
        end
      end
    end
  end
end
