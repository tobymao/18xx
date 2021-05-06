# frozen_string_literal: true

require_relative '../../../token'

module Engine
  module Game
    module G1840
      module Step
        class SpecialToken < Engine::Step::Token
          ACTIONS = %w[place_token pass].freeze

          def actions(entity)
            return [] unless entity == pending_entity

            ACTIONS
          end

          def round_state
            super.merge(
              {
                pending_special_tokens: [],
              }
            )
          end

          def active?
            pending_entity
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
            @round.pending_special_tokens&.first || {}
          end

          def description
            'Place free Token'
          end

          def available_tokens(_entity)
            [token]
          end

          def process_place_token(action)
            hex = action.city.hex
            unless available_hex(action.entity, hex)
              raise GameError, "Cannot place token on #{hex.name} as the hex is not available"
            end

            token.price = 0

            place_token(
              token.corporation,
              action.city,
              token,
              connected: true,
              extra_action: true,
            )
            @round.pending_tokens.shift
          end

          def process_pass(action)
            super
            @round.pending_tokens.shift
          end

          def show_other
            @game.owning_major_corporation(current_entity)
          end
        end
      end
    end
  end
end
