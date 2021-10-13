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
            city = action.city
            token = city.tokens[action.slot]
            hex = city.hex
            entity = action.entity

            raise GameError, "Cannot place token on #{hex.name} as the hex is not available" unless available_hex(entity, hex)

            if token&.corporation&.type == :city
              check_connected(entity, city, hex)
              spender = @game.owning_major_corporation(entity)
              spender.spend(40, @game.bank)
              @log << "#{entity.name} removes token from #{hex.name} (#{hex.location_name}) "\
                      "for #{@game.format_currency(40)}"
              token.destroy!
            end

            action.token.price = 0

            place_token(
              entity,
              city,
              action.token,
              extra_action: true,
            )

            @game.city_graph.clear
            @round.pending_special_tokens.shift
          end

          def process_pass(action)
            super
            @round.pending_special_tokens.shift
          end

          def show_other
            @game.owning_major_corporation(current_entity)
          end

          def can_replace_token?(_entity, _token)
            true
          end
        end
      end
    end
  end
end
