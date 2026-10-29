# frozen_string_literal: true

require_relative '../../../step/track'
require_relative '../../../step/tokener'

module Engine
  module Game
    module GFrost1831
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::Tokener

          def round_state
            super.merge({ faction_acted: false, favor_mode: false })
          end

          def setup
            super
            @round.faction_acted = false if @round.respond_to?(:faction_acted=)
            @game.assign_favor_to_current_operator(current_entity) if current_entity
          end

          def actions(entity)
            return %w[choose] if entity&.company? && entity.sym == 'FAV'

            return [] unless entity == current_entity

            if entity.type == :faction
              return [] unless @game.parliament_open?
              return [] unless entity.floated?
              return [] if @round.respond_to?(:faction_acted) && @round.faction_acted
              return [] unless faction_can_act?(entity)

              acts = []
              acts << 'lay_tile' if can_lay_tile?(entity)
              acts << 'place_token' if can_place_faction_token?(entity)
              acts << 'pass' unless acts.empty?
              return acts
            end

            super
          end

          # Factions cannot upgrade NL or GJ (only yellow lays allowed)
          def available_hex(entity_or_entities, hex)
            entities = Array(entity_or_entities)
            entity = entities.first

            if entity&.type == :faction
              # Block NL/GJ upgrades
              if %w[D7 M6].include?(hex.id) && hex.tile.color != :white
                return nil
              end

              # Allow hex if it's a valid token placement city
              return true if can_place_faction_token?(entity) &&
                             @game.available_faction_cities(entity).include?(hex.id)
            end

            # Fix stale graph cache: if entity has tokens but graph shows no connected hexes,
            # clear and recompute. This can happen when graph was computed before home token.
            if entity && entity.type != :faction
              has_tokens = entity.tokens.any? { |t| t.city }
              graph = @game.graph_for_entity(entity)
              connected = graph.connected_hexes(entity)
              if has_tokens && connected.empty?
                graph.clear
              end
            end

            super
          end

          def process_place_token(action)
            entity = action.entity
            city = action.city
            token = action.token
            hex = city.hex

            # Reject bases outside the legal set (prevents duplicate base in same city)
            unless @game.loading
              unless @game.available_faction_cities(entity).include?(hex.id)
                if hex.tile.cities.any? { |c| c.tokens.any? { |t| t&.corporation == entity } }
                  raise GameError, "#{entity.name} already has a base in #{hex.id}"
                end

                raise GameError, "#{entity.name} cannot place a base on #{hex.id}"
              end
            end

            cubes = @game.faction_influence(entity.id)
            cost = GFrost1831::Step::Token::BASE_INFLUENCE_COST
            raise GameError, "#{entity.name} needs #{cost} Influence but has #{cubes}" if cubes < cost

            tokens_total = entity.tokens.size - 1
            tokens_used = entity.share_price&.coordinates&.[](1) || 0
            tokens_available = [tokens_total - tokens_used, 0].max
            raise GameError, "#{entity.name} has no available tokens" unless tokens_available.positive?

            city.place_token(entity, token, check_tokenable: false)

            cost.times { @game.faction_influence_lose(entity.id) }
            @log << "#{entity.name} places a token on #{action.city.hex.name} for #{cost} Influences"

            # Faction value increases
            @game.stock_market.move_right(entity)
            entity.par_price = entity.share_price
            @log << "#{entity.name}'s value increases to #{@game.format_currency(entity.share_price.price)}"

            @round.faction_acted = true if @round.respond_to?(:faction_acted=)
          end

          def blocking_for_entity?(entity)
            return false if entity&.company? && entity.sym == 'FAV'

            super
          end

          def process_choose(action)
            return unless action.entity&.sym == 'FAV'

            special_choose = @round.steps.find { |s| s.is_a?(GFrost1831::Step::SpecialChoose) }
            special_choose&.process_choose_ability(action)
          end

          def description
            if current_entity&.type == :faction
              'Place a Token or Lay Track'
            else
              super
            end
          end

          def pass_description
            return 'Skip (Token/Track)' if current_entity&.type == :faction

            super
          end

          def lay_tile(action, **kwargs)
            entity = action.entity
            hex = action.hex

            if entity.type == :faction
              hex = action.hex
              tile = action.tile

              # NL and GJ always cost £50 extra for upgrades
              if %w[D7 M6].include?(hex.id) && hex.tile.color != :white
                raise GameError, "#{entity.name} cannot upgrade New London or Grand Junction"
              end

              influence_cost = faction_tile_cost(hex, tile)

              faction_influence_count = @game.faction_influence(entity.id)
              if faction_influence_count < influence_cost
                raise GameError, "#{entity.name} needs #{influence_cost} Influence but only has #{faction_influence_count}"
              end

              super(action, **kwargs)

              influence_cost.times { @game.faction_influence_lose(entity.id) }

              @log << "#{entity.name} lays tile ##{tile.name} with rotation #{action.rotation} "\
                      "on #{hex.name} for #{influence_cost} Influence"

              @round.faction_acted = true if @round.respond_to?(:faction_acted=)

              @game.after_lay_tile(hex, tile, entity)
              return
            end

            old_tile = action.hex.tile
            super
            @game.after_lay_tile(action.hex, action.tile, action.entity)
          end

          def pay_tile_cost!(entity, tile, rotation, hex, spender, cost, _extra_cost)
            return if entity.type == :faction

            super
          end

          def log_skip(entity)
            if entity.type == :faction
              @log << "#{entity.name} passes place a token or lay track"
              return
            end

            super
          end

          private

          def faction_can_act?(entity)
            @game.faction_influence(entity.id) >= 1
          end

          def can_place_faction_token?(entity)
            return false unless entity&.type == :faction

            cubes = @game.faction_influence(entity.id)
            return false unless cubes >= GFrost1831::Step::Token::BASE_INFLUENCE_COST
            return false if @game.available_faction_cities(entity).empty?

            # Use market position to determine available tokens (same as status_array).
            # Each move_right (favor, base, turmoil) consumes 1 token from the pool.
            # Faction starts at column 0 (£70); current column = tokens consumed.
            tokens_total = entity.tokens.size - 1  # 8 additional tokens
            tokens_used = entity.share_price&.coordinates&.[](1) || 0
            tokens_available = [tokens_total - tokens_used, 0].max
            return false unless tokens_available.positive?

            true
          end

          def faction_tile_cost(hex, tile)
            if tile.color == :yellow
              terrain_cost = 0
              hex.tile.upgrades.each do |upgrade|
                next unless upgrade.cost&.positive?

                terrain_cost += mountain_influence_cost(upgrade.cost)
              end
              1 + terrain_cost
            else
              case tile.color
              when :green then 2
              when :brown then 3
              when :gray then 4
              else 1
              end
            end
          end

          def mountain_influence_cost(money_cost)
            # £50 mountain = 1 extra cube, £80 mountain = 2 extra cubes
            case money_cost
            when 50 then 1
            when 80 then 2
            else 0
            end
          end
        end
      end
    end
  end
end
