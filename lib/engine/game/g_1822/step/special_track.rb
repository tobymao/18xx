# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'tracker'

module Engine
  module Game
    module G1822
      module Step
        class SpecialTrack < Engine::Step::Base
          include Engine::Game::G1822::Tracker

          ACTIONS = %w[lay_tile].freeze

          def actions(entity)
            action = abilities(entity)
            return [] unless action

            ACTIONS
          end

          def description
            'Lay Track'
          end

          def blocks?
            false
          end

          def process_lay_tile(action)
            entity = action.entity
            ability = abilities(entity)
            spender = if !entity.owner
                        nil
                      elsif entity.owner.corporation?
                        entity.owner
                      else
                        @game.current_entity
                      end
            if @game.company_ability_extra_track?(entity)
              upgraded_extra_track = upgraded_track?(action)
              raise GameError, 'Cannot lay an extra upgrade' if upgraded_extra_track && @extra_laided_track

              lay_tile(action, spender: spender)
              if upgraded_extra_track || spender.type == :minor
                # Use the ability an extra time, upgrade counts as 2 tile lays. Or if its a minor, they ony get one use
                ability.use!
              else
                @extra_laided_track = true
              end
            else
              lay_tile_action(action, spender: spender)
            end
            @game.after_lay_tile(action.hex, action.tile)
            ability.use!

            return if ability.count.positive? || !ability.closed_when_used_up

            @log << "#{ability.owner.name} closes"
            ability.owner.close!
          end

          def available_hex(entity, hex)
            return unless (ability = abilities(entity))
            return if !ability.hexes&.empty? && !ability.hexes&.include?(hex.id)

            operator = entity.owner.corporation? ? entity.owner : @game.current_entity
            connected = hex_neighbors(operator, hex)
            return nil unless connected

            return connected if @game.company_ability_extra_track?(entity)

            tile_lay = get_tile_lay(operator)
            return nil unless tile_lay

            color = hex.tile.color
            return nil if color == :white && !tile_lay[:lay]
            return nil if color != :white && !tile_lay[:upgrade]
            return nil if color != :white && tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(hex)

            # London yellow tile counts as an upgrade
            if hex.tile.color == :white && @round.num_laid_track.positive? && hex.name == @game.class::LONDON_HEX
              return nil
            end

            # Middleton Railway can only lay track on hexes with one town
            return nil if entity.id == @game.class::COMPANY_MTONR && (hex.tile.towns.empty? || hex.tile.towns.size > 1)

            # Bristol & Exeter Railway can only lay track on plain hexes or with one town
            if entity.id == @game.class::COMPANY_BER && @game.class::TRACK_PLAIN.none?(hex.tile.name) &&
              @game.class::TRACK_TOWN.none?(hex.tile.name)
              return nil
            end

            # If player have choosen the tile lay option on the Edinburgh and Glasgow Railway company,
            # only rough terrain, hill or mountains are valid hexes
            if entity.id == @game.class::COMPANY_EGR
              tile_terrain = hex.tile.upgrades.any? do |upgrade|
                %i[mountain hill swamp].any? { |t| upgrade.terrains.include?(t) }
              end
              return nil unless tile_terrain
            end

            connected
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless entity.id == @game.class::COMPANY_MTONR

            true
          end

          def potential_tiles(entity, hex)
            return [] unless (tile_ability = abilities(entity))
            return super if tile_ability.tiles.empty?

            tiles = tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
            special = tile_ability.special if tile_ability.type == :tile_lay
            if entity.id == @game.class::COMPANY_BER
              return tiles.compact
                .select { |t| @game.upgrades_to?(hex.tile, t, special) }
            end
            tiles
              .compact
              .select { |t| @game.phase.tiles.include?(t.color) && @game.upgrades_to?(hex.tile, t, special) }
          end

          def abilities(entity, **kwargs, &block)
            return unless entity&.company?

            @game.abilities(
              entity,
              :tile_lay,
              time: %w[special_track %current_step% owning_corp_or_turn],
              **kwargs,
              &block
            )
          end
        end
      end
    end
  end
end
