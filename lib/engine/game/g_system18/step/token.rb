# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module GSystem18
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if entity.receivership?
            return [] unless entity == current_entity

            actions = []
            actions << 'place_token' if can_place_token?(entity)
            actions << 'choose' if can_remove_icon?(entity)
            actions << 'pass' unless actions.empty?

            actions
          end

          def description
            if can_place_token?(current_entity)
              return "#{@game.removable_icon_action_str} or Place a Token" if can_remove_icon?(current_entity)
            elsif can_remove_icon?(current_entity)
              return @game.removable_icon_action_str
            end
            'Place a Token'
          end

          def can_remove_icon?(entity)
            @game.can_remove_icon?(entity)
          end

          def choices
            @game.icon_hexes(current_entity)
          end

          def render_choices?
            false
          end

          def process_choose(action)
            entity = action.entity
            hex_id = action.choice

            @game.remove_icon(entity, hex_id)
          end

          def process_place_token(action)
            entity = action.entity

            place_token(entity, action.city, action.token,
                        same_hex_allowed: @game.token_same_hex?(entity, action.city.hex, action.token))
            pass!
          end

          def check_connected(entity, city, hex)
            @game.tokener_check_connected(entity, city, hex) && super
          end

          def tokener_available_hex(entity, hex)
            @game.icon_hexes(entity).include?(hex.id) ||
              (@game.tokener_available_hex(entity, hex) && super)
          end
        end
      end
    end
  end
end
