# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative '../../../step/track_lay_when_company_sold'

module Engine
  module Game
    module G1822Africa
      module Step
        class LayGameReserve < Engine::Step::SpecialTrack
          include Engine::Step::TrackLayWhenCompanySold

          def abilities(entity, **kwargs, &block)
            return unless entity&.company?

            if acquired_companies.include?(entity)
              ability = @game.abilities(entity, :tile_lay, time: 'sold', **kwargs, &block)
              return ability if ability
            end

            nil
          end

          def blocking_for_sold_company?
            @company = acquired_companies.find do |company|
              @game.abilities(company, :tile_lay, time: 'sold')
            end
          end

          def acquired_companies
            return [] unless @round.respond_to?(:acquired_companies)

            @round.acquired_companies
          end

          def get_sold_company_ability(entity = nil)
            acquired_companies = @round.respond_to?(:acquired_companies) && @round.acquired_companies
            entities = [entity, *acquired_companies].compact

            entities.each do |company|
              ability = @game.abilities(company, :tile_lay, time: 'sold')
              return ability if ability
            end

            nil
          end

          def available_hex(entity, hex)
            return unless (ability = abilities(entity))

            ability.hexes&.include?(hex.id) && hex.tile.color == :white
          end

          def legal_tile_rotation?(entity_or_entities, hex, tile)
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            return @game.legal_tile_rotation?(entity, hex, tile) unless @game.tile_game_reserve?(tile)

            # Only check than tile exits don't connect to map edges
            tile.exits.all? { |edge| hex.neighbors[edge] }
          end

          def process_lay_tile(action)
            super

            @game.pay_game_reserve_bonus!(action.entity)

            @log << "#{action.entity.name} closes"
            action.entity.close!
          end

          def potential_tiles(entity_or_entities, _hex)
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            return [] unless (tile_ability = abilities(entity))

            tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
          end
        end
      end
    end
  end
end
