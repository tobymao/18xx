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

          def place_second_oo_token(tile, corp_name)
            corporation = @game.corporation_by_id(corp_name)
            return unless corporation&.floated

            token = corporation.next_token
            city = tile.cities.reject(&:tokened?).first
            city.place_token(corporation, token) if city.tokenable?(corporation, tokens: token)
          end

          def swap_higher_value_oo_token(city, entity)
            old_token = city.tokens.first
            old_token.remove!
            city.exchange_token(entity.find_token_by_type)
          end

          def process_place_token(action)
            super
            tile = action.city.tile
            other_corp =
              case [action.entity.name, tile.name]
              when %w[NWR 235]
                'SPD'
              when %w[SPD 235]
                swap_higher_value_oo_token(action.city, action.entity)
                'NWR'
              when %w[EBR 235]
                swap_higher_value_oo_token(action.city, action.entity)
                'EIR'
              when %w[EIR 235]
                'EBR'
              end

            return unless other_corp

            place_second_oo_token(tile, other_corp)
            @round.pending_tokens.shift
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
            return if (hex.name == 'G8') || (hex.name == 'P17')

            @game.tiles.select { |t| %w[13 12 206 205].include?(t.name) }.uniq(&:name)
          end
        end
      end
    end
  end
end
