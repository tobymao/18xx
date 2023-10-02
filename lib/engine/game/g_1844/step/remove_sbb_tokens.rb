# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1844
      module Step
        class RemoveSBBTokens < Engine::Step::Base
          REMOVE_TOKEN_ACTIONS = %w[remove_token].freeze

          def actions(entity)
            return [] if entity != current_entity || hexes_to_resolve(entity).empty?

            REMOVE_TOKEN_ACTIONS
          end

          def description
            'Remove token'
          end

          def help
            "#{current_entity.name} cannot have two tokens in the same hex. "\
              "Select which token to remove from #{hexes_to_resolve(current_entity).map(&:id).join(',')}."
          end

          def active_entities
            [@game.sbb]
          end

          def can_replace_token?(entity, token)
            available_hex(entity, token.hex)
          end

          def hexes_to_resolve(entity)
            entity.tokens.select(&:used).map(&:hex).group_by(&:itself).select { |_k, v| v.size > 1 }.keys
          end

          def available_hex(entity, hex)
            hexes_to_resolve(entity).include?(hex)
          end

          def process_remove_token(action)
            entity = action.entity
            token = action.city.tokens[action.slot]
            hex = token.hex

            raise GameError, "Cannot remove #{token.corporation.name} token" if !@game.loading && !available_hex(entity, hex)

            @log << "#{entity.name} removes token from #{hex.full_name} and places it on its charter"
            token.remove!
          end
        end
      end
    end
  end
end
