# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1894
      module Step
        class UpdateTokens < Engine::Step::Base
          ACTIONS = %w[place_token].freeze

          def actions(entity)
            return [] unless entity == current_entity

            ACTIONS
          end

          def active?
            pending_entity
          end

          def active_entities
            [pending_entity]
          end

          def current_entity
            pending_entity
          end

          def pending_entity
            pending_token[:entity]
          end

          def token
            pending_token[:token]
          end

          def pending_token
            @game.saved_tokens&.first || {}
          end

          def description
            "Choose city for token in #{@game.saved_tokens_hex.name}"
          end

          def available_hex(_entity, hex)
            pending_token[:hexes].include?(hex)
          end

          def available_tokens(_entity)
            [token]
          end

          def process_place_token(action)
            # the action is faked and doesn't represent the actual token laid
            hex = action.city.hex

            raise GameError, "Cannot place token on #{hex.name} as the hex is not available" unless available_hex(action.entity,
                                                                                                                  hex)

            cheater = action.city.tokens.count { |t| !t.nil? }
            action.city.place_token(action.entity, token, free: true, check_tokenable: false, cheater: cheater)
            @log << "#{corporation.id} places a token on #{hex_id} (#{hex.location_name})"
            saved_tokens = @game.saved_tokens
            saved_tokens.shift
            @game.save_tokens(saved_tokens)
          end

          def token_cost_override(_entity, _city_hex, _slot, _token)
            nil
          end

          def can_replace_token?(_entity, _token)
            true
          end
        end
      end
    end
  end
end
