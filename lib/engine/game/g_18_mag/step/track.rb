# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'pay_tile'

module Engine
  module Game
    module G18Mag
      module Step
        class Track < Engine::Step::Track
          include G18Mag::Step::PayTile
          K_HEXES = %w[I2 H23 H27].freeze
          BUY_ACTION = %w[special_buy].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.corporation? || entity.company? || !can_lay_tile?(entity)

            buyable_items(entity).empty? ? ACTIONS : ACTIONS + BUY_ACTION
          end

          def round_state
            super.merge(
              {
                terrain_token: nil,
              }
            )
          end

          def setup
            super

            @round.terrain_token = nil
          end

          def buyable_items(entity)
            return [] unless @game.terrain_tokens[entity.name]&.positive?
            return [] if @round.terrain_token

            [Item.new(description: 'Use Terrain Token', cost: 0)]
          end

          def item_str(item)
            item.description
          end

          def process_special_buy(action)
            entity = action.entity
            @round.terrain_token = true

            @game.terrain_tokens[entity.name] -= 1

            @log << "#{entity.name} spends a Terrain Token (#{@game.terrain_tokens[entity.name]} left)"
          end

          def log_skip(entity)
            super unless entity.corporation?
          end

          def process_lay_tile(action)
            old_tile = action.hex.tile
            super
            old_tile.label = nil if old_tile.color == :yellow && old_tile.label.to_s == 'K'
            return unless K_HEXES.include?(action.hex.coordinates)

            # Handle special upgrade rules from K hexes
            action.tile.label = 'K' if action.tile.color == :yellow
          end

          # handle yellow OO tile
          def update_token!(_action, _entity, tile, old_tile)
            cities = tile.cities
            if old_tile.paths.empty? &&
                !tile.paths.empty? &&
                cities.size > 1 &&
                (token = cities.flat_map(&:tokens).find(&:itself))

              # always move token to city with index 0
              token.move!(cities[0])
              @game.graph.clear
            end
          end

          def tile_lay_abilities_should_block?(entity)
            ability_time = %w[track owning_player_track]
            Array(abilities(entity, time: ability_time, passive_ok: false)).any? { |a| !a.consume_tile_lay } &&
            @game.phase.available?('Green')
          end
        end
      end
    end
  end
end
