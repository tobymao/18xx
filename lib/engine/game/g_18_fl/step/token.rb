# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18FL
      module Step
        class Token < Engine::Step::Token
          ACTIONS = %w[place_token hex_token pass].freeze
          INFINITE_DISTANCE = 99_999

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless can_place_token?(entity)

            ACTIONS
          end

          def can_place_token?(entity)
            !@game.round.laid_token[entity] && (
              !@game.token_company.closed? ||
              (current_entity == entity &&
                !(tokens = available_tokens(entity)).empty? &&
                min_token_price(tokens) <= buying_power(entity))
            )
          end

          def process_place_token(action)
            raise GameError, "#{action.entity.name} cannot lay token now" if @game.round.laid_token[action.entity]

            if action.cost > action.entity.cash
              raise GameError, "#{action.entity.name} cannot afford "\
                               "#{@game.format_currency(action.cost)} to lay token in "\
                               "#{action.city.hex.tile.location_name}"
            end

            unless @game.loading
              verified_cost = token_cost_override(action.entity, action.city, action.slot, action.token)
              raise GameError, 'Error verifying token cost; is game out of sync?' unless action.cost == verified_cost
            end
            action.token.price = action.cost
            super
            @game.round.laid_token[action.entity] = true
          end

          def available_hex(entity, hex)
            @game.graph.reachable_hexes(entity)[hex]
          end

          def process_hex_token(action)
            entity = action.entity
            hex = action.hex
            token = action.token

            raise GameError, "#{hex.id} is not a town" if hex.tile.towns.empty?

            tokener = hex_tokened(hex)
            raise GameError, "#{tokener.name} already has a hotel in #{hex.tile.location_name}" if tokener

            cost = action.cost # We are using token_cost_override
            unless @game.loading
              # Since the view for hex_token does this to determine the `verified_token` going in
              # but doesn't pass that to the action, we repeat it here
              next_token = available_tokens(entity)[0].type
              verified_token = entity.find_token_by_type(next_token&.to_sym)
              verified_cost = token_cost_override(entity, hex, nil, verified_token)
              raise GameError, 'Error verifying token cost; is game out of sync?' unless cost == verified_cost
            end
            raise GameError, "#{entity.name} cannot afford #{@game.format_currency(cost)} cost to lay hotel" if cost > entity.cash

            @game.log << "#{entity.name} places a hotel on #{hex.name} for #{@game.format_currency(cost)}"
            entity.spend(cost, @game.bank)

            hex.place_token(token)
            pass!
          end

          def token_cost_override(entity, city_hex, _slot, token)
            node = city_hex.respond_to?(:city?) ? city_hex : city_hex.tile.towns.first
            min_distance = INFINITE_DISTANCE
            goal_cities = entity.tokens.select(&:city).map(&:city)
            return if node.nil?

            node.walk(corporation: entity) do |path, visited_paths, _visited|
              if goal_cities.include?(path.city)
                # minus one to account for the tokened hex getting included in the count
                distance = visited_paths.uniq { |k, _| k.hex }.size - 1
                min_distance = [min_distance, distance].min
              end
            end

            token.price * min_distance
          end

          def hex_tokened(hex)
            @game.corporations.find { |c| tokened(hex, c) }
          end

          def tokened(hex, entity)
            hex.tile.icons.any? { |i| i.name == entity.id }
          end
        end
      end
    end
  end
end
