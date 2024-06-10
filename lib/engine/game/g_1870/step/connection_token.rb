# frozen_string_literal: true

require_relative '../../../step/token'
require_relative 'connection'

module Engine
  module Game
    module G1870
      module Step
        class ConnectionToken < Engine::Step::Token
          include Connection

          STATION_WARS_CORPS = %w[GMO MP SP SSW TP].freeze

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
              token_placement_arg =
                if @game.station_wars? && STATION_WARS_CORPS.include?(entity.id)
                  { cheater: true }
                else
                  { extra_slot: true }
                end
              destination.tile.cities.first.place_token(entity, token, free: true, **token_placement_arg)
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
