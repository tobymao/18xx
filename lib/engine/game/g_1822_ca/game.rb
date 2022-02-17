# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1822CA
      class Game < G1822::Game
        include_meta(G1822CA::Meta)
        include G1822CA::Entities
        include G1822CA::Map

        MINOR_14_ID = nil

        STARTING_COMPANIES = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18 P19 P20 P21
                                C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                M16 16 M17 M18 M19 M20 M21 M22 M23 M24 M25 M26 M27 M28 M29 M30].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
                                   30 LNWR GWR LBSCR SECR CR MR LYR NBR SWR NER].freeze

        def init_hexes(companies, corporations)
          blockers = {}
          (companies + minors + corporations).each do |company|
            abilities(company, :blocks_hexes) do |ability|
              ability.hexes.each do |hex|
                blockers[hex] = company
              end
            end
          end

          partition_blockers = {}
          partition_companies.each do |company|
            abilities(company, :blocks_partition) do |ability|
              partition_blockers[ability.partition_type] = company
            end
          end

          reservations = Hash.new { |k, v| k[v] = [] }
          reservation_corporations.each do |c|
            Array(c.coordinates).each_with_index do |coord, idx|
              reservations[coord] << {
                entity: c,
                city: c.city.is_a?(Array) ? c.city[idx] : c.city,
              }
            end
          end

          (corporations + companies).each do |c|
            abilities(c, :reservation) do |ability|
              reservations[ability.hex] << {
                entity: c,
                city: ability.city.to_i,
                slot: ability.slot.to_i,
                ability: ability,
              }
            end
          end

          optional_hexes.map do |color, hexes|
            hexes.map do |coords, tile_string|
              coords.map.with_index do |coord, index|
                next Hex.new(coord, layout: layout, axes: axes, empty: true) if color == :empty

                tile =
                  begin
                    Tile.for(tile_string, preprinted: true, index: index)
                  rescue Engine::GameError
                    Tile.from_code(coord, color, tile_string, preprinted: true, index: index)
                  end

                if (blocker = blockers[coord])
                  tile.add_blocker!(blocker)
                end

                tile.partitions.each do |partition|
                  if (blocker = partition_blockers[partition.type])
                    partition.add_blocker!(blocker)
                  end
                end

                reservations[coord].each do |res|
                  res[:ability].tile = tile if res[:ability]
                  tile.add_reservation!(res[:entity], res[:city], res[:slot])
                end

                # name the location (city/town)
                location_name = location_name(coord)

                Hex.new(coord, layout: layout, axes: axes, tile: tile, location_name: location_name)
              end
            end
          end.flatten.compact
        end

        def setup_destinations; end
      end
    end
  end
end
