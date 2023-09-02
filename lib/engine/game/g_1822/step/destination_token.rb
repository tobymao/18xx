# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1822
      module Step
        class DestinationToken < Engine::Step::Base
          ACTIONS = %w[hex_token pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless can_place_token?(entity)

            self.class::ACTIONS
          end

          def auto_actions(entity)
            return [Engine::Action::Pass.new(entity)] unless destination_node_check?(entity)

            [Engine::Action::HexToken.new(entity,
                                          hex: @game.hex_by_id(entity.destination_coordinates),
                                          token_type: available_tokens(entity).first.type)]
          end

          def available_tokens(entity)
            destination_token = entity.find_token_by_type(:destination)
            return [] unless destination_token

            [destination_token]
          end

          def can_place_token?(entity)
            return false if !entity.corporation? || (entity.corporation? && entity.type != :major)

            !available_tokens(entity).empty?
          end

          def description
            'Place the Destination Token'
          end

          def pass_description
            'Skip (Destination Token)'
          end

          def available_hex(entity, hex)
            entity.destination_coordinates == hex.name
          end

          def destination_node_check?(entity)
            destination_hex = @game.hex_by_id(entity.destination_coordinates)
            home_node = entity.tokens.first.city
            destination_hex.tile.nodes.first&.walk(corporation: entity) do |path, _, _|
              return true if path.nodes.include?(home_node)
            end
            false
          end

          def process_hex_token(action)
            entity = action.entity
            hex = action.hex
            # This ignores the token on the action, as for a few games it was incorrectly set to a 'normal' token
            token = available_tokens(entity).first
            raise GameError, 'Corporation does not have a destination token unused' unless token

            if !@game.loading && !destination_node_check?(entity)
              raise GameError, "Can't place the destination token on #{hex.name} "\
                               'because it is not connected'
            end

            @game.place_destination_token(entity, hex, token)
            @game.remove_extra_tokens!(hex.tile)
            pass!
          end

          def process_pass(action)
            entity = action.entity
            if !@game.loading && destination_node_check?(entity)
              raise GameError, "#{entity.name} cannot skip placing its destination token when it has a connection "\
                               "to #{entity.destination_coordinates}"
            end

            super
          end

          def skip!
            pass!
          end

          def token_cost_override(_entity, _city_hex, _slot, _token)
            nil
          end
        end
      end
    end
  end
end
