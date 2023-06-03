# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'tracker'

module Engine
  module Game
    module G1822
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include Engine::Game::G1822::Tracker

          def actions(entity)
            return ACTIONS_WITH_PASS if @company == entity

            action = abilities(entity) && @game.round.active_step.respond_to?(:process_lay_tile)
            return [] unless action

            ACTIONS
          end

          def description
            @company ? "Lay Track for #{@company.name}" : 'Lay Track'
          end

          def process_lay_tile(action)
            old_tile = action.hex.tile
            entity = action.entity
            entities = [entity, *action.combo_entities]

            raise GameError, "Cannot combine #{entities.map(&:id).join('+')}" unless @game.valid_combos?(entities)

            ability = abilities(entity)
            spender = if !entity.owner
                        nil
                      elsif entity.owner.corporation?
                        entity.owner
                      else
                        @game.current_entity
                      end
            @in_process = true

            minor_single_use = false

            if entities.any? { |e| @game.company_ability_extra_track?(e) }
              upgraded_extra_track = upgraded_track?(action.hex.tile, action.tile, action.hex)
              consume_tile_lay = entities.flat_map(&:all_abilities).find { |a| a.type == :tile_lay && a.consume_tile_lay }
              if upgraded_extra_track && @extra_laided_track && consume_tile_lay
                raise GameError,
                      'Cannot lay an extra upgrade'
              end

              lay_tile(action, spender: spender)
              @round.laid_hexes << action.hex
              if spender.type == :minor
                minor_single_use = true
              else
                @extra_laided_track = true
              end
            else
              lay_tile_action(action, spender: spender)
            end
            @in_process = false
            @game.after_lay_tile(action.hex, old_tile, action.tile)

            active_abilities = [ability, *action.combo_entities.map { |e| e.all_abilities.find { |a| a.type == :tile_lay } }]
            active_abilities.each do |ability_|
              ability_.use!(upgrade: %i[green brown gray].include?(action.tile.color))
              ability_.use! if minor_single_use

              next unless ability_.type == :tile_lay

              if ability_.count <= 0 && ability_.closed_when_used_up
                @log << "#{ability_.owner.name} closes"
                ability_.owner.close!
              end

              handle_extra_tile_lay_company(ability_, ability_.owner)
            end

            return unless ability.type == :teleport

            @round.teleported = ability.owner
          end

          def process_pass(action)
            super
            @log << "#{action.entity.name} closes"
            action.entity.close!
          end

          def available_hex(entity_or_entities, hex)
            # entity_or_entities is an array when combining private company abilities
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            return unless (ability = abilities(entity))
            return if !ability.hexes&.empty? && !ability.hexes&.include?(hex.id)
            return @game.hex_by_id(hex.id).neighbors.keys if ability.type == :teleport

            operator = entity.owner.corporation? ? entity.owner : @game.current_entity
            connected = hex_neighbors(operator, hex)
            return nil unless connected

            return connected if entity.id == @game.class::COMPANY_HSBC

            if (tile_lay = get_tile_lay(operator)) && (tile_lay[:lay] || tile_lay[:upgrade])
              color = hex.tile.color
              return nil if color == :white && !tile_lay[:lay]
              return nil if color != :white && !tile_lay[:upgrade]
              return nil if color != :white && tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(hex)
            else
              # P12 gives extra tile lay
              return nil unless entities.any? { |e| @game.company_ability_extra_track?(e) }
            end

            # P2 Middleton Railway can only lay track on hexes with one town
            # (town remover)
            return nil if entities.any? { |e| @game.must_remove_town?(e) } && (hex.tile.towns.empty? || hex.tile.towns.size > 1)

            # P11 Bristol & Exeter Railway can only lay track on plain hexes or
            # with one town, and on the phase's latest color (advanced tile lay)
            if entities.any? { |e| @game.can_only_lay_plain_or_towns?(e) } &&
               @game.class::TRACK_PLAIN.none?(hex.tile.name) &&
               @game.class::TRACK_TOWN.none?(hex.tile.name)
              return nil
            end
            if entities.any? { |e| @game.can_upgrade_one_phase_ahead?(e) } &&
                hex.tile.color != @game.phase.tiles.last
              return nil
            end

            # P8 Edinburgh and Glasgow Railway company can
            # only lay track on hills and mountains
            if entities.any? { |e| @game.must_be_on_terrain?(e) }
              tile_terrain = hex.tile.upgrades.any? do |upgrade|
                %i[mountain hill].any? { |t| upgrade.terrains.include?(t) }
              end
              return nil unless tile_terrain
            end

            # P10 Glasgow and South-Western Railway's tile lay ability must be
            # on an estuary
            if entities.any? { |e| @game.must_be_on_estuary?(e) } && hex.tile.borders.none? { |b| b.type.to_s == 'water' }
              return nil
            end

            # unless otherwise specified and returned, private must be connected
            connected
          end

          def legal_tile_rotation?(entity_or_entities, hex, tile)
            # entity_or_entities is an array when combining private company abilities
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            return tile.rotation.zero? if entity.id == @game.class::COMPANY_LCDR && hex.name == @game.class::ENGLISH_CHANNEL_HEX

            # check for P2 (Remove Town)
            return legal_tile_rotation_remove_town?(entity.owner, hex, tile) if entities.any? { |e| @game.must_remove_town?(e) }

            super
          end

          def legal_tile_rotation_remove_town?(entity, hex, tile)
            return false unless @game.legal_tile_rotation?(entity, hex, tile)

            old_paths = hex.tile.paths

            new_paths = tile.paths
            new_exits = tile.exits

            new_exits.all? { |edge| hex.neighbors[edge] } &&
              !(new_exits & hex_neighbors(entity, hex)).empty? &&
              old_paths_are_preserved(old_paths, new_paths)
          end

          def old_paths_are_preserved(old_paths, new_paths)
            # We are removing a town (P2), just check the exits
            old_exits = old_paths.flat_map(&:exits).uniq
            new_exits = new_paths.flat_map(&:exits).uniq
            (old_exits - new_exits).empty?
          end

          def potential_tiles(entity_or_entities, hex)
            # entity_or_entities is an array when combining private company abilities
            entities = Array(entity_or_entities)
            entity, *combo_entities = entities

            return [] unless (tile_ability = abilities(entity))

            tile_abilities = [
              tile_ability,
              *combo_entities.map { |e| e.all_abilities.find { |a| a.type == :tile_lay } },
            ]

            use_default = true

            tile_abilities.each_with_object([]) do |tile_ability_, tiles|
              if use_default && !tile_ability_.tiles.empty?
                use_default = false
                tiles.clear
              end
              ability_tiles = use_default ? super : potential_tiles_for_entity(tile_ability_.owner, hex, tile_ability_)
              tiles.concat(ability_tiles)
            end
          end

          def potential_tiles_for_entity(entity, hex, tile_ability)
            advanced_tile_lay = @game.can_upgrade_one_phase_ahead?(entity)
            return [] if advanced_tile_lay && entity.owner.type == :minor && !hex.tile.color == :yellow

            special = tile_ability.special if tile_ability.type == :tile_lay

            tile_ability.tiles.each_with_object([]) do |name, tiles|
              next unless (tile = @game.tiles.find { |t| t.name == name })
              next unless @game.upgrades_to?(hex.tile, tile, special)

              # Advanced Tile Lay private only wants tiles from a future phase,
              # all others want to match the current phase
              next if advanced_tile_lay == @game.phase.tiles.include?(tile.color)

              tiles << tile
            end
          end

          def abilities(entity, **kwargs, &block)
            return unless entity&.company?

            if entity.id == @game.class::COMPANY_LCDR && !@in_process
              tile = @game.hex_by_id(@game.class::ENGLISH_CHANNEL_HEX).tile
              city = tile.cities.first
              phase_color = @game.phase.current[:tiles].last
              # P5 London, Chatham and Dover Railway may only use its tile_lay
              # option if all slots is taken and an upgrade can make a slot
              # available. this is green to brown, and brown to grey
              return if city.available_slots.positive? ||
                @game.exchange_tokens(entity.owner).zero? ||
                (tile.color == :green && !%i[brown gray].include?(phase_color)) ||
                (tile.color == :brown && phase_color != :gray)
            end

            if entity.id == @game.class::COMPANY_HSBC && entity.owner&.corporation?
              return if @round.num_laid_track.positive? && entity != @game.current_entity

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

          def hex_neighbors(entity, hex)
            @game.graph_for_entity(entity).connected_hexes(entity)[hex]
          end

          # Extra Tile Lay abilities need to be used either entirely before
          # or entirely after the Major's normal tile lays
          # https://boardgamegeek.com/thread/2425653/article/34793831#34793831
          def handle_extra_tile_lay_company(ability, entity)
            @company =
              if ability.must_lay_together
                @round.num_laid_track += 1 if @round.num_laid_track == 1 && !ability.consume_tile_lay
                ability.count.positive? ? entity : nil
              end
          end
        end
      end
    end
  end
end
