# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1858India
      module Step
        class CollectTokens < Engine::Step::Base
          ACTIONS = %w[remove_hex_token pass].freeze
          TOKEN_COST = { 'mine' => 50,  'oil' => 100, 'port' => 200 }.freeze

          def actions(entity)
            return [] unless current_entity == entity
            return [] unless entity.corporation?
            return [] unless can_collect_token?(entity, false)

            ACTIONS
          end

          def auto_actions(entity)
            # Checking whether a corporation has a route to an available token
            # involves recalculating the game graphs, which is expensive, so
            # `actions` only checks if there is an available token somewhere on
            # the board.
            # To avoid asking the player to choose tokens when none are really
            # available, insert an auto-action pass.
            return unless entity.corporation?
            return if can_collect_token?(entity, true)

            [Engine::Action::Pass.new(entity)]
          end

          def description
            'Collect mine, oil and port tokens'
          end

          def help
            'Collect mine tokens ' \
              "(#{@game.format_currency(TOKEN_COST['mine'])} each), " \
              'oil tokens ' \
              "(#{@game.format_currency(TOKEN_COST['oil'])} each) " \
              'and port tokens ' \
              "(#{@game.format_currency(TOKEN_COST['port'])} each)."
          end

          def log_skip(entity)
            super unless entity.minor?
          end

          def available_hex(entity, hex)
            can_remove_hex_token?(entity, hex)
          end

          def can_remove_hex_token?(entity, hex)
            connected_tokens(entity).map(&:hex).include?(hex)
          end

          def process_remove_hex_token(action)
            corporation = action.entity
            hex = action.hex
            token = hex.tokens.first
            price = token_price(token)

            msg = "#{corporation.id} "
            msg += "spends #{@game.format_currency(price)} and " if price.positive?
            msg += "collects a #{token_type(token)} token from " \
                   "hex #{hex.coordinates}."
            @game.log << msg
            corporation.spend(price, @game.bank) if price.positive?
            hex.remove_token(token)
            corporation.tokens << token
          end

          private

          def can_collect_token?(entity, check_graph)
            if check_graph
              !connected_tokens(entity).empty?
            else
              !available_tokens(entity).empty?
            end
          end

          # Returns all mine/oil/port tokens on the map which have not yet
          # been collected, where there has been track laid in the hex.
          # For port tokens the corporation must be able to afford the token
          # and the current phase must allow them to be taken.
          def available_tokens(corporation)
            tokens = []
            tokens.concat(mines) if corporation.cash >= TOKEN_COST['mine']
            tokens.concat(oil) if corporation.cash >= TOKEN_COST['oil']
            tokens.concat(ports) if corporation.cash >= TOKEN_COST['port']
            tokens
          end

          # Returns all mine/oil/port tokens where the corporation has a route
          # to the hex, where the corporation can afford to take the token and
          # the current phase must allow it to be taken.
          # Calling this method might cause the game graphs to be recalculated.
          def connected_tokens(corporation)
            available_tokens(corporation).select do |token|
              @game.graph_broad.reachable_hexes(corporation).include?(token.hex) ||
              @game.graph_metre.reachable_hexes(corporation).include?(token.hex)
            end
          end

          def token_price(token)
            TOKEN_COST[token.corporation.id]
          end

          def token_type(token)
            token.corporation.id
          end

          def hex_tokens(hexes)
            hexes.flat_map(&:tokens).reject { |t| t.hex.tile.color == :white }
          end

          def mines
            hex_tokens(@game.mine_hexes)
          end

          def oil
            return [] unless @game.phase.status.include?('oil_tokens')

            hex_tokens(@game.oil_hexes)
          end

          def ports
            return [] unless @game.phase.status.include?('port_tokens')

            hex_tokens(@game.port_hexes)
          end
        end
      end
    end
  end
end
