# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'
require_relative '../../../step/track_lay_when_company_sold'

module Engine
  module Game
    module G1822Africa
      module Step
        class SpecialTrack < G1822::Step::SpecialTrack
          include Engine::Step::TrackLayWhenCompanySold

          # this makes track_lay_when_company_sold work with acquire_company step
          def blocking_for_sold_company?
            @company = nil
            just_sold_companies = @round.respond_to?(:acquired_companies) && @round.acquired_companies

            just_sold_companies.each do |company|
              if @game.abilities(company, :tile_lay, time: 'sold')
                @company = company
                return true
              end
            end

            false
          end

          def potential_tiles_for_entity(_entity, hex, tile_ability)
            special = tile_ability.special if tile_ability.type == :tile_lay

            tile_ability.tiles.each_with_object([]) do |name, tiles|
              next unless (tile = @game.tiles.find { |t| t.name == name })
              next unless @game.upgrades_to?(hex.tile, tile, special)

              tiles << tile
            end
          end

          def available_hex(entity, hex)
            return super unless @game.company_game_reserve?(entity)
            return unless (ability = abilities(entity))

            ability.hexes&.include?(hex.id) && hex.tile.color == :white
          end

          def legal_tile_rotation?(entity_or_entities, hex, tile)
            return super unless @game.tile_game_reserve?(tile)

            # Only check than tile exits don't connect to map edges
            tile.exits.all? { |edge| hex.neighbors[edge] }
          end

          def process_lay_tile(action)
            super

            return unless @game.company_game_reserve?(action.entity)

            # process_lay_tile from G1822::SpecialTrack isn't called because TrackLayWhenCompanySold skips it here
            @game.pay_game_reserve_bonus!(action)
            @log << "#{action.entity.name} closes"
            action.entity.close!
          end
        end
      end
    end
  end
end
