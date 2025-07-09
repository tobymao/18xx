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

          def actions(entity)
            return [] unless entity == pending_entity

            actions = []
            actions << 'place_token' if any_open_cities?
            actions << 'lay_tile' if any_town_hex?

            actions
          end

          def any_open_cities?
            !@game.open_city_hexes.empty?
          end

          def any_town_hex?
            !@game.town_to_green_city_hexes.empty?
          end

          def description
            "Lay home token in open city or upgrade town for #{pending_entity.name}"
          end

          def process_lay_tile(action)
            lay_tile(action)

            place_token(
              action.entity,
              action.tile.cities[0],
              token,
              connected: false,
              extra_action: true
            )

            @round.pending_tokens.shift
          end

          def process_place_token(action)
            super
            tile = action.city.tile
            # apply "other" OO token once first to operate is applied if floated
            if action.entity.name == 'NWR' && tile.name == '235'
              corporation = @game.corporations.find { |c| c.name == 'SPD' }
              if corporation&.floated
                token = corporation.find_token_by_type
                city = tile.cities.reject(&:tokened?).first
                city.place_token(corporation, token) if city.tokenable?(corporation, tokens: token)
              end
              @round.pending_tokens.shift
            elsif action.entity.name == 'SPD' && tile.name == '235'
              # remove and swap the NWR that appeared... hacky...
              city = action.city
              old_token = city.tokens[0]
              old_token.remove!
              city.exchange_token(action.entity.find_token_by_type)

              # apply "other" OO token once first to operate is applied if floated
              corporation = @game.corporations.find { |c| c.name == 'NWR' }
              if corporation&.floated
                token = corporation.find_token_by_type
                city = tile.cities.reject(&:tokened?).first
                city.place_token(corporation, token) if city.tokenable?(corporation, tokens: token)
              end
              @round.pending_tokens.shift
            end
            # otherwise make sure reservations are preserved
            replace_oo_reservations(tile) unless tile.reservations.empty? # move hex reservation
          end

          # Base code doesn't handle one token and one reservation on a OO tile
          # Moves a reservation from hex to untoken city
          def replace_oo_reservations(tile)
            return unless tile.name == '235'

            corp = tile.reservations.first
            city = tile.cities.reject(&:tokened?).first
            city.add_reservation!(corp)
            tile.reservations.clear
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
            return if hex.name == 'G8'

            @game.tiles.select { |t| %w[13 12 206 205].include?(t.name) }.uniq(&:name)
          end
        end
      end
    end
  end
end
