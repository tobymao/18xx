# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1849
      module Step
        class BuyToken < Engine::Step::Base
          ACTIONS = %w[buy_token pass].freeze
          MIN_PRICE = 1

          def actions(entity)
            return [] if !@game.acquiring_station_tokens? || !entity.corporation? || entity != current_entity

            ACTIONS
          end

          def setup
            @bought_token = false
          end

          def can_buy_token?(entity)
            @game.buy_tokens_enabled &&
              !@bought_token &&
              !available_tokens(entity).empty? &&
              MIN_PRICE <= buying_power(entity)
          end

          def available_tokens(entity)
            entity.tokens_by_type
          end

          def can_sell_token?(token, entity)
            token != token.corporation.tokens.first &&
            !token.city.tokened_by?(entity)
          end

          def any_buyable_tokens_placed?(entity)
            @game.token_graph_for_entity(entity).connected_nodes(entity).keys.each do |node|
              next unless node.city?

              node.tokens.each do |token|
                next unless token
                next if token.corporation == entity

                return true if can_sell_token?(token, entity)
              end
            end
            false
          end

          def log_skip(entity)
            super if @game.acquiring_station_tokens?
          end

          def log_pass(entity)
            super if @game.acquiring_station_tokens?
          end

          def auto_actions(entity)
            return [Engine::Action::Pass.new(entity)] unless any_buyable_tokens_placed?(entity)

            super
          end

          # Can't buy a token from another corp if your corp already has a token on that city
          def can_token_city?(entity, city)
            city.tile.nodes.select(&:city?).none? { |c| c.tokened_by?(entity) }
          end

          def can_replace_token?(entity, token)
            return false unless token

            other_corporation = token.corporation
            city = token.city
            entity != other_corporation &&
              token.hex.id != other_corporation.tokens.first.hex.id &&
              other_corporation.player &&
              token.used &&
              city &&
              can_token_city?(entity, city) &&
              (city.pass? || other_corporation.placed_tokens.count { |t| !t.city.pass? } > 1) &&
              @game.token_graph_for_entity(entity).connected_nodes(entity)[city]
          end

          def description
            'Buy a Token From Another Corporation'
          end

          def max_price(entity)
            buying_power(entity)
          end

          def available_hex(entity, hex)
            @game.token_graph_for_entity(entity).reachable_hexes(entity)[hex]
          end

          def process_buy_token(action)
            entity = action.entity
            city = action.city
            slot = action.slot
            price = action.price
            old_token = city.tokens[slot]

            raise GameError, 'No token available to place' unless (new_token = entity.unplaced_tokens.first)
            raise GameError, 'Cannot replace token' if !@game.loading && !can_replace_token?(entity, old_token)
            raise GameError, 'Insufficient cash for token' if buying_power(entity) < price
            raise GameError, "Cannot buy other corporation's home token" if city == old_token.corporation.tokens.first.city

            old_token.remove!
            city.exchange_token(new_token)
            entity.spend(price, old_token.corporation)
            @game.log << "#{entity.name} buys (replaces) #{old_token.corporation.name} token on #{city.hex.id} for "\
                         "#{@game.format_currency(price)} (paid to #{old_token.corporation.name})"

            @bought_token = true
            @game.token_graph_for_entity(entity).clear

            # kill routes for corp selling token
            @game.graph.clear_graph_for(old_token.corporation)
          end

          def real_owner(corporation)
            corporation.player
          end
        end
      end
    end
  end
end
