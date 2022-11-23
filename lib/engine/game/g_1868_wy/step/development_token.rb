# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1868WY
      module Step
        class DevelopmentToken < Engine::Step::Base
          ACTIONS = {
            coal: %w[hex_token pass],
            oil: %w[hex_token remove_hex_token pass],
          }.freeze

          def description
            'Development Token'
          end

          def help
            send("help_#{current_entity.type}")
          end

          def help_coal
            if current_entity == @game.union_pacific_coal
              if current_entity.find_token_by_type(:development)
                'You may place the UP Development Token for free.'
              else
                'You may move the UP Development Token for free.'
              end
            elsif (max = @game.max_development_tokens(current_entity)) == 1
              'You may place a Development Token, paying (but not removing) any terrain cost on the chosen hex.'
            elsif max > 1
              "You may place up to #{max} Development Tokens, paying (but not removing) any terrain costs on the chosen hexes."
            end
          end

          def help_oil
            unless current_entity == @game.bonanza
              return 'You may remove any number of Oil Development Tokens, and place 1 more than you remove'
            end

            if current_entity.find_token_by_type(:development)
              'You may place the BZ Oil Development Token for free.'
            else
              'You may move the BZ Oil Development Token for free.'
            end
          end

          def setup
            @net_tokens_placed = 0
          end

          def actions(entity)
            return [] unless entity.minor?
            return ACTIONS[entity.type] if can_place_token?(entity)
            return %w[remove_hex_token pass] if can_remove_token?(entity)

            []
          end

          def log_pass(entity)
            super if entity.minor?
          end

          def pass!
            super
            @game.after_strikebreakers if current_entity == @game.strikebreakers_coal
          end

          def log_skip(entity)
            return if entity.corporation?

            super
          end

          def available_hex(entity, hex)
            @game.available_development_hex?(entity, hex)
          end

          def available_tokens(entity)
            return [] unless entity.minor?

            tokens = [entity.find_token_by_type(:development)].compact
            if entity == @game.union_pacific_coal || entity.type == :coal
              tokens.select! { |t| t.logo.end_with?("#{@game.coal_phase}.svg") }
            end
            return tokens unless tokens.empty?

            if @net_tokens_placed.zero? && (entity == @game.union_pacific_coal || entity == @game.bonanza)
              entity.tokens.reject(&:used)
            else
              []
            end
          end

          def can_place_token?(entity)
            return false if entity.type == :oil && @game.placed_oil_dt_count[entity] == 3

            max_tokens = @game.max_development_tokens(entity)
            @net_tokens_placed < max_tokens && !available_tokens(entity).empty?
          end

          def can_remove_token?(entity)
            entity.type == :oil &&
              @net_tokens_placed.zero? &&
              @game.placed_oil_dt_count[entity].positive?
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

            if !action.token && (entity == @game.union_pacific_coal || entity == @game.bonanza)
              action = Engine::Action::HexToken.new(
                entity,
                hex: hex,
                cost: cost,
                token: entity.tokens.first
              )
            end

            @game.place_development_token(action)
            @game.placed_oil_dt_count[entity] += 1
            @net_tokens_placed += 1
          end

          def process_remove_hex_token(action)
            entity = action.entity
            hex = action.hex

            raise GameError, "#{entity.name} cannot remove a Development Token" unless entity.type == :oil

            token = hex.tokens.find { |t| t.corporation == entity }
            @game.remove_oil_development_token!(token)
            @game.placed_oil_dt_count[entity] -= 1
            @net_tokens_placed -= 1
          end

          def token_cost_override(entity, city_hex, _slot, _token)
            if entity == @game.union_pacific_coal || entity == @game.bonanza
              0
            else
              cost = city_hex.tile.upgrades.sum(&:cost)

              if entity.player == @game.fremont&.player && (discount = [20, cost].min).positive?
                cost -= discount
              end

              cost /= 2 if entity.player == @game.pac_rr_a&.player && cost.positive?

              cost
            end
          end
        end
      end
    end
  end
end
