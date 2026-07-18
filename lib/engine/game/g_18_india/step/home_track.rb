# frozen_string_literal: true

require_relative '../../../step/home_token'
require_relative '../../../step/tracker'

module Engine
  module Game
    module G18India
      module Step
        class HomeTrack < Engine::Step::HomeToken
          include Engine::Step::Tracker
          ACTIONS = %w[lay_tile place_token].freeze

          def round_state
            super.merge(pending_tokens: [])
          end

          def pending_token
            @round.pending_tokens&.find do |pending|
              next true unless @game.oo_corporation?(pending[:entity])

              oo_on_yellow_tile?(pending)
            end || {}
          end

          def actions(entity)
            return [] unless entity == pending_entity

            actions = []
            actions << 'place_token' if any_open_cities?
            actions << 'lay_tile' if any_town_hex? && entity == @game.gipr

            actions
          end

          def any_open_cities?
            pending = pending_token
            return oo_on_yellow_tile?(pending) if oo_pending?(pending)

            !@game.open_city_hexes.empty?
          end

          def oo_pending?(pending)
            @game.oo_corporation?(pending[:entity]) || @game.oo_corporation?(pending[:token]&.corporation)
          end

          def oo_on_yellow_tile?(pending)
            hex = pending[:hexes]&.first
            hex && !hex.tile.paths.empty?
          end

          def any_town_hex?
            !@game.town_to_green_city_hexes.empty?
          end

          def description
            corp = token&.corporation
            if corp && pending_entity != corp
              "Place #{corp.name} token"
            else
              "Lay home token in open city or upgrade town for #{pending_entity.name}"
            end
          end

          def process_lay_tile(action)
            pending = pending_token
            lay_tile(action)

            place_token(
              action.entity,
              action.tile.cities[0],
              pending[:token],
              connected: false,
              extra_action: true
            )

            @round.pending_tokens.delete(pending)
          end

          def auto_actions(entity)
            return unless (pending = pending_token)
            return unless pending[:hexes]&.one?

            hex = pending[:hexes].first
            cities = hex.tile.cities.reject(&:tokened?)
            return unless cities.one?

            [Engine::Action::PlaceToken.new(entity, city: cities.first, token: pending[:token])]
          end

          def hex_neighbors(_entity, hex)
            pending_token[:hexes].include?(hex)
          end

          def available_hex(_entity, hex)
            pending_token[:hexes].include?(hex)
          end

          def legal_tile_rotation?(_entity, hex, tile)
            old_tile = hex.tile
            all_new_exits_valid = tile.exits.all? { |edge| hex.neighbors[edge] }
            return false unless all_new_exits_valid

            (old_tile.exits - tile.exits).empty?
          end

          def potential_tiles(_entity_or_entities, hex)
            return if (hex.name == 'G8') || (hex.name == 'P17')

            @game.tiles.select { |t| %w[13 12 206 205].include?(t.name) }.uniq(&:name)
          end
        end
      end
    end
  end
end
