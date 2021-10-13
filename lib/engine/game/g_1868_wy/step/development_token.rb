# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1868WY
      module Step
        class DevelopmentToken < Engine::Step::Base
          ACTIONS = %w[hex_token pass].freeze

          def description
            'Development Token'
          end

          def actions(entity)
            return [] unless entity.minor?
            return [] unless can_place_token?(entity)

            ACTIONS
          end

          def log_pass(entity)
            super if entity.minor?
          end

          def log_skip(entity); end

          def available_hex(entity, hex)
            @game.available_coal_hex?(hex) if entity.type == :coal
          end

          def available_tokens(entity)
            return [] unless entity.minor?

            [entity.find_token_by_type(:development)].compact
          end

          def can_place_token?(entity)
            !available_tokens(entity).empty?
          end

          def process_hex_token(action)
            entity = action.entity
            player = entity.player
            hex = action.hex
            cost = action.cost

            unless @game.loading
              # Since the view for hex_token does this to determine the `verified_token` going in
              # but doesn't pass that to the action, we repeat it here
              next_token_type = available_tokens(entity)[0].type
              verified_token = entity.find_token_by_type(next_token_type&.to_sym)
              verified_cost = token_cost_override(entity, hex, nil, verified_token)
              raise GameError, 'Error verifying token cost; is game out of sync?' unless cost == verified_cost
            end

            if cost > player.cash
              raise GameError, "#{player.name} cannot afford #{@game.format_currency(cost)} "\
                               'cost to place Development Token'
            end

            @game.place_development_token(action)
          end

          def token_cost_override(_entity, city_hex, _slot, _token)
            city_hex.tile.upgrades.sum(&:cost)
          end
        end
      end
    end
  end
end
