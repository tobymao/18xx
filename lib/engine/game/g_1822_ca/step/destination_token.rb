# frozen_string_literal: true

require_relative '../../g_1822/step/destination_token'

module Engine
  module Game
    module G1822CA
      module Step
        class DestinationToken < G1822::Step::DestinationToken
          ACTIONS = %w[hex_token place_token pass].freeze

          def setup
            @connected_destination_nodes = []
          end

          def actions(entity)
            return [] if @game.destinated?(entity)

            super
          end

          def auto_actions(entity)
            return [Engine::Action::Pass.new(entity)] unless destination_node_check?(entity)

            # ICR cannot auto-destinate if it is connected to multiple Quebec cities
            return if @connected_destination_nodes.size > 1

            destination_hex = @game.hex_by_id(entity.destination_coordinates)
            if destination_hex.tile.cities.one? || !@game.destination_city(destination_hex, entity).is_a?(Array)
              [Engine::Action::HexToken.new(entity,
                                            hex: @game.hex_by_id(entity.destination_coordinates),
                                            token_type: available_tokens(entity).first.type)]
            else
              # if there are multiple Quebec cities and ICR is connected to only
              # one, it can auto-destinate, but the destination city needs to be
              # tracked
              city = @connected_destination_nodes[0]
              [Engine::Action::PlaceToken.new(entity,
                                              city: city,
                                              slot: city.get_slot(entity),
                                              token_type: available_tokens(entity).first.type)]
            end
          end

          def process_hex_token(action)
            entity = action.entity
            hex = action.hex

            if !@game.loading && !destination_node_check?(entity)
              raise GameError, "Can't place the destination token on #{hex.name} "\
                               'because it is not connected'
            end
            if @connected_destination_nodes.size > 1
              raise GameError, "#{entity.name} is connected to multiple cities on the hex. Click "\
                               'on the city where it should place its destination token.'
            end

            super
          end

          def process_place_token(action)
            entity = action.entity
            city = action.city
            hex = city.hex
            token = action.token
            raise GameError, 'Corporation does not have a destination token unused' unless token

            if !@game.loading && !destination_node_check?(entity)
              raise GameError, "Can't place the destination token on #{hex.name} "\
                               'because it is not connected'
            end

            @game.place_destination_token(entity, hex, token, city)
            @game.remove_extra_tokens!(hex.tile)

            # interactions with ICR's destination and QMOO's home
            @game.update_home(@game.qmoo) if entity == @game.icr

            pass!
          end

          def destination_node_check?(entity)
            destination_hex = @game.hex_by_id(entity.destination_coordinates)
            home_node = entity.tokens.first.city

            destination_nodes = Array(@game.destination_city(destination_hex, entity))

            @connected_destination_nodes = destination_nodes.select do |destination_node|
              nodes_connected?(destination_node, home_node, entity)
            end

            !@connected_destination_nodes.empty?
          end

          def nodes_connected?(node_a, node_b, entity)
            LOGGER.debug { "    nodes_connected?(#{node_a}, #{node_b}, #{entity.name})" }
            walk_calls = Hash.new(0)

            node_a&.walk(corporation: entity, walk_calls: walk_calls) do |path, _, _|
              if path.nodes.include?(node_b)
                LOGGER.debug do
                  "    nodes_connected? returning true after #{walk_calls[:not_skipped]} "\
                    "walk calls (#{walk_calls[:skipped]} skipped)"
                end
                return true
              end
            end

            LOGGER.debug do
              "    nodes_connected? returning false after #{walk_calls[:not_skipped]} "\
                "walk calls (#{walk_calls[:skipped]} skipped)"
            end

            false
          end

          # not actually replacing a token, but ICR sometimes needs to choose
          # its home and it might need to choose a city that is full of tokens
          def can_replace_token?(entity, _token)
            entity == @game.icr
          end
        end
      end
    end
  end
end
