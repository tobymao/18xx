# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18ZOO
      module Step
        class Track < Engine::Step::Track
          include Engine::Game::G18ZOO::ChooseAbilityOnOr

          TILES = {
            '7' => '3',
            '8' => '58',
            '9' => '4',
          }.freeze

          def actions(entity)
            return ['choose_ability'] if entity.company? && can_choose_ability?(entity)

            super
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            hex = action.hex
            tile = action.tile

            return super unless %w[O M MM].include?(hex.tile.label.to_s)

            if hex.tile.label.to_s == 'O' && tile.color == :yellow
              new_tile = Tile.for(TILES[tile.name]).dup
              new_tile.index = tile.index
              new_tile.icons = [Engine::Part::Icon.new('river', 'river', true, true)]
              new_label = 'O'
              @game.tiles << new_tile
              @game.tiles.delete(tile)
              super(Engine::Action::LayTile.new(action.entity, hex: hex, tile: new_tile, rotation: action.rotation))
              new_tile.label = new_label
            elsif %w[M MM].include?(hex.tile.label.to_s) && tile.color == :yellow
              new_label = hex.tile.label.to_s
              super
              tile.label = new_label
              tile.icons = [Engine::Part::Icon.new('18_zoo/mountain', 'mountain', true, true)]
            end
          end

          private

          def can_choose_ability?(company)
            entity = @game.current_entity
            return false if entity.player?

            # p "Track.can_choose_ability?(#{company.name})" # TODO: use for debug
            return true if can_choose_ability_on_any_step(entity, company)

            false
          end
        end
      end
    end
  end
end
