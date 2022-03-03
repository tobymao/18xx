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
            action = abilities(entity) && @game.round.active_step.respond_to?(:process_lay_tile)
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
            old_tile = action.hex.tile
            entity = action.entity
            ability = abilities(entity)
            spender = if !entity.owner
                        nil
                      elsif entity.owner.corporation?
                        entity.owner
                      else
                        @game.current_entity
                      end
            @in_process = true
            if @game.company_ability_extra_track?(entity)
              upgraded_extra_track = upgraded_track?(action.hex.tile, action.tile, action.hex)
              raise GameError, 'Cannot lay an extra upgrade' if upgraded_extra_track && @extra_laided_track

              lay_tile(action, spender: spender)
              @round.laid_hexes << action.hex
              if upgraded_extra_track || spender.type == :minor
                # Use the ability an extra time, upgrade counts as 2 tile lays. Or if its a minor, they ony get one use
                ability.use!
              else
                @extra_laided_track = true
              end
            else
              lay_tile_action(action, spender: spender)
            end
            @in_process = false
            @game.after_lay_tile(action.hex, old_tile, action.tile)
            ability.use!

            if ability.type == :tile_lay && ability.count <= 0 && ability.closed_when_used_up
              @log << "#{ability.owner.name} closes"
              ability.owner.close!
            end

            return unless ability.type == :teleport

            @round.teleported = ability.owner
          end

          def available_hex(entity, hex)
            return unless (ability = abilities(entity))
            return if !ability.hexes&.empty? && !ability.hexes&.include?(hex.id)
            return @game.hex_by_id(hex.id).neighbors.keys if ability.type == :teleport

            operator = entity.owner.corporation? ? entity.owner : @game.current_entity
            connected = hex_neighbors(operator, hex)
            return nil unless connected

            return connected if @game.company_ability_extra_track?(entity)
            return connected if entity.id == @game.class::COMPANY_HSBC

            tile_lay = get_tile_lay(operator)
            return nil unless tile_lay

            color = hex.tile.color
            return nil if color == :white && !tile_lay[:lay]
            return nil if color != :white && !tile_lay[:upgrade]
            return nil if color != :white && tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(hex)

            # Middleton Railway can only lay track on hexes with one town
            return nil if @game.must_remove_town?(entity) && (hex.tile.towns.empty? || hex.tile.towns.size > 1)

            # Bristol & Exeter Railway can only lay track on plain hexes or with one town
            if @game.can_only_lay_plain_or_towns?(entity) && @game.class::TRACK_PLAIN.none?(hex.tile.name) &&
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
            return tile.rotation.zero? if entity.id == @game.class::COMPANY_LCDR && hex.name == @game.class::ENGLISH_CHANNEL_HEX
            return legal_tile_rotation_remove_town?(entity.owner, hex, tile) if @game.must_remove_town?(entity)

            super
          end

          def legal_tile_rotation_remove_town?(entity, hex, tile)
            return false unless @game.legal_tile_rotation?(entity, hex, tile)

            old_paths = hex.tile.paths
            old_ctedges = hex.tile.city_town_edges

            new_paths = tile.paths
            new_exits = tile.exits
            new_ctedges = tile.city_town_edges
            extra_cities = [0, new_ctedges.size - old_ctedges.size].max
            multi_city_upgrade = new_ctedges.size > 1 && old_ctedges.size > 1

            new_exits.all? { |edge| hex.neighbors[edge] } &&
              !(new_exits & hex_neighbors(entity, hex)).empty? &&
              old_paths_are_preserved(old_paths, new_paths) &&
              extra_cities >= new_ctedges.count { |newct| old_ctedges.all? { |oldct| (newct & oldct).none? } } &&
              (!multi_city_upgrade ||
                old_ctedges.all? { |oldct| new_ctedges.one? { |newct| (oldct & newct) == oldct } })
          end

          def old_paths_are_preserved(old_paths, new_paths)
            # We are removing a town, just check the exits
            old_exits = old_paths.flat_map(&:exits).uniq
            new_exits = new_paths.flat_map(&:exits).uniq
            (old_exits - new_exits).empty?
          end

          def potential_tiles(entity, hex)
            return [] unless (tile_ability = abilities(entity))
            return super if tile_ability.tiles.empty?

            tiles = tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
            special = tile_ability.special if tile_ability.type == :tile_lay
            if @game.can_upgrade_one_phase_ahead?(entity)
              return tiles.compact
                .select { |t| @game.upgrades_to?(hex.tile, t, special) }
            end
            tiles
              .compact
              .select { |t| @game.phase.tiles.include?(t.color) && @game.upgrades_to?(hex.tile, t, special) }
          end

          def abilities(entity, **kwargs, &block)
            return unless entity&.company?

            if entity.id == @game.class::COMPANY_LCDR && !@in_process
              tile = @game.hex_by_id(@game.class::ENGLISH_CHANNEL_HEX).tile
              city = tile.cities.first
              phase_color = @game.phase.current[:tiles].last
              # London, Chatham and Dover Railway may only use its tilelay option if all slots is taken and an
              # upgrade can make a slot available. this is green to brown, and brown to grey
              return if city.available_slots.positive? ||
                @game.exchange_tokens(entity.owner).zero? ||
                (tile.color == :green && !%i[brown gray].include?(phase_color)) ||
                (tile.color == :brown && phase_color != :gray)
            end

            if entity.id == @game.class::COMPANY_HSBC && entity.owner&.corporation?
              hsbc_token = entity.owner.tokens
                            .select(&:used)
                            .any? { |t| @game.class::COMPANY_HSBC_TILES.include?(t.city.hex.id) }
              return unless hsbc_token
            end

            %i[tile_lay teleport].each do |type|
              ability = @game.abilities(
                entity,
                type,
                time: %w[special_track %current_step% owning_corp_or_turn],
                **kwargs,
                &block
              )
              return ability if ability && (ability.type != :teleport || !ability.used?)
            end

            nil
          end

          def round_state
            super.merge(
              {
                teleported: nil,
              }
            )
          end
        end
      end
    end
  end
end
