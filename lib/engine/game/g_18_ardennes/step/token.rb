# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Token < Engine::Step::Token
          ACTIONS = %w[place_token remove_token pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless can_place_token?(entity)

            ACTIONS
          end

          def auto_actions(entity)
            return if token_graph(entity).can_token?(entity)
            return if can_replace_dummy_token?(entity)

            [Engine::Action::Pass.new(entity)]
          end

          def token_graph(entity)
            @token_graph ||= @game.token_graph_for_entity(entity)
          end

          def can_place_token?(entity)
            current_entity == entity &&
              !@round.tokened &&
              !(tokens = available_tokens(entity)).empty? &&
              min_token_price(tokens) <= buying_power(entity)
          end

          # Is this a dummy port or mine token?
          def dummy_token?(token)
            token.corporation.type == :dummy
          end

          # Returns true if the corporation has a route to a port or
          # mine token that can be replaced.
          def can_replace_dummy_token?(entity)
            token_graph(entity).connected_nodes(entity).any? do |node, _|
              node.city? && node.tokens.compact.any? { |token| dummy_token?(token) }
            end
          end

          def can_replace_token?(entity, token)
            dummy_token?(token) &&
              token_graph(entity).connected_nodes(entity).include?(token.city)
          end

          # The `remove_token` action is used to replace a port or mine token
          # with a corporation's token.
          def process_remove_token(action)
            corp = action.entity
            city = action.city
            check_connected(corp, city, city.hex)

            city.tokens[action.slot].remove!
            place_token(corp, city, available_tokens(corp).first)
            corp.assign!(city.hex.coordinates)
            pass!
          end
        end
      end
    end
  end
end
