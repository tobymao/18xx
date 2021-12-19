# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G18USA
      module Tracker
        TRACK_ENGINEER_TILE_LAYS = [ # Three lays with one being an upgrade, second tile costs 20, third tile free
            { lay: true, upgrade: true },
            { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
            { lay: true, upgrade: :not_if_upgraded, cost: 0, cannot_reuse_same_hex: true },
          ].freeze

        NORMAL_TILE_LAYS = [ # Two lays with one being an upgrade, second tile costs 20
            { lay: true, upgrade: true },
            { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
          ].freeze

        def round_state
          super.merge({
                        tile_lay_mode: :standard,
                        great_northern_track: false,
                        pettibone_upgrade: false,
                      })
        end

        def track_upgrade?(from, to, _hex)
          # yellow+ -> something else, or fast tracking plain track
          super || (from.cities.size.zero? && to.cities.size.zero? &&
            (Engine::Tile::COLORS.index(to.color) - Engine::Tile::COLORS.index(from.color) > 1))
        end

        def can_lay_tile?(entity)
          super || could_do_great_northern?(entity)
        end

        def could_do_brown_home_tile_lay?(entity)
          @game.phase.tiles.include?(:brown) && @game.recently_floated.include?(entity) &&
              %i[white yellow green].include?(@game.home_hex_for(entity).tile.color) &&
              !@round.laid_hexes.include?(@game.home_hex_for(entity))
        end

        def brown_home_action
          {
            lay: true,
            upgrade: true,
            cost: 0,
            cannot_reuse_same_hex: true,
          }
        end

        def could_do_great_northern?(entity)
          corporation = entity&.company? ? entity.owner : entity
          !@game.company_by_id('P17').closed? && @game.company_by_id('P17').owner == corporation && !@round.great_northern_track
        end

        def great_northern_action
          {
            lay: true,
            upgrade: false,
            cost: 0,
            cannot_reuse_same_hex: true,
          }
        end

        def could_do_track_engineers?(entity)
          corporation = entity&.company? ? entity.owner : entity
          !@game.company_by_id('P7').closed? && @game.company_by_id('P7').owner == corporation
        end

        def tile_lay_eligible_for_track_engineers?(old_tile, new_tile, _entity)
          old_tile.color == :white &&
          new_tile.color == :yellow &&
          @round.num_laid_track >= 2
        end

        def could_do_pettibone?(entity)
          corporation = entity&.company? ? entity.owner : entity
          !@game.company_by_id('P11').closed? &&
              @game.company_by_id('P11').owner == corporation &&
              !@round.pettibone_upgrade
        end

        def tile_lay_eligible_for_pettibone?(old_tile, new_tile, _entity)
          old_tile.cities.empty? && new_tile.cities.empty? && # plain track only
          # must be an upgrade
          track_upgrade?(old_tile, new_tile) &&
          # the power not used yet
          !@round.pettibone_upgrade
        end

        def get_tile_lay(entity)
          corporation = get_tile_lay_corporation(entity)
          return brown_home_action if @round.tile_lay_mode == :brown_home && could_do_brown_home_tile_lay?(entity)

          tile_lays = (could_do_track_engineers?(corporation) ? TRACK_ENGINEER_TILE_LAYS : NORMAL_TILE_LAYS)
          action = tile_lays[@round.num_laid_track]&.clone
          return unless action

          action[:lay] = !@round.upgraded_track if action[:lay] == :not_if_upgraded
          action[:upgrade] = !@round.upgraded_track if action[:upgrade] == :not_if_upgraded
          action[:upgrade] = true if @round.tile_lay_mode == :pettibone
          action[:cost] = action[:cost] || 0
          action[:upgrade_cost] = action[:upgrade_cost] || action[:cost]
          action[:cannot_reuse_same_hex] = action[:cannot_reuse_same_hex] || false
          action
        end

        def lay_tile_action(action, entity: nil, spender: nil)
          tile = action.tile
          old_tile = action.hex.tile
          tile_lay = get_tile_lay(action.entity)
          raise GameError, 'Cannot lay an upgrade now' if track_upgrade?(old_tile, tile,
                                                                         action.hex) && !(tile_lay && tile_lay[:upgrade])
          raise GameError, 'Cannot lay a yellow now' if tile.color == :yellow && !(tile_lay && tile_lay[:lay])
          if tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(action.hex)
            raise GameError, "#{action.hex.id} cannot be layed as this hex was already layed on this turn"
          end

          if @round.tile_lay_mode == :brown_home && (action.hex != @game.home_hex_for(action.entity) || tile.color != :brown)
            raise GameError, "Must upgrade home to brown in #{tile_lay_mode_desc(@round.tile_lay_mode)} mode"
          end
          if @round.tile_lay_mode == :pettibone && !tile_lay_eligible_for_pettibone?(old_tile, tile, entity)
            raise GameError, 'Only plain track upgrades can be used for Pettibone & Mulliken power'
          end

          extra_cost = tile.color == :yellow ? tile_lay[:cost] : tile_lay[:upgrade_cost]

          lay_tile(action, extra_cost: extra_cost || 0, entity: entity, spender: spender)

          # Only record the upgrade if not a pettibone upgrade; the pettibone upgrade is tracked separately
          @round.upgraded_track = true if track_upgrade?(old_tile, tile, action.hex) &&
              !%i[pettibone brown_home].include?(@round.tile_lay_mode)

          case @round.tile_lay_mode
          when :pettibone
            @round.pettibone_upgrade = true
            @round.num_laid_track += 1
          when :standard
            @round.num_laid_track += 1
          end

          @round.laid_hexes << action.hex
          switch_tile_lay_mode(action.entity, :standard) if @round.tile_lay_mode != :standard
        end

        def tile_lay_mode_desc(mode)
          return 'Standard' if mode == :standard
          return 'Brown Home' if mode == :brown_home
          return 'P&M Upgrade' if mode == :pettibone

          'unknown'
        end

        def upgradeable_tiles(_entity, hex)
          tiles = super
          @game.filter_by_max_edges(tiles)
          # When upgrading normal cities to brown, players must use tiles with as many exits as will fit.
          # Find maximum number of exits
        end

        # super references @game.upgrades_to? which doesn't have the context of entity
        # which means we need to clamp down here on if it is legal do to the yellow/white -> brown
        # upgrade check
        def potential_tiles(entity, hex)
          super.reject do |tile|
            !tile.cities.empty? && tile.color == :brown && hex.tile.color != :green &&
                hex != @game.home_hex_for(entity) && @round.tile_lay_mode != :brown_home
          end
        end

        def process_choose(action)
          switch_tile_lay_mode(action.entity, action.choice)
        end

        def switch_tile_lay_mode(entity, new_mode)
          @game.log << "#{entity.name} switches to #{tile_lay_mode_desc(new_mode)} tile lay mode"
          @round.tile_lay_mode = new_mode
        end

        def choice_available?(entity)
          !choices_for_entity(entity).empty?
        end

        def choice_name
          "Tile lay mode to use; current is #{tile_lay_mode_desc(@round.tile_lay_mode)}"
        end

        def choices
          choices_for_entity(current_entity)
        end

        def choices_for_entity(entity)
          choices = {
            standard: 'Standard tile lay',
          }.freeze
          choices[:brown_home] = 'Brown Home tile lay' if could_do_brown_home_tile_lay?(entity)
          choices[:pettibone] = 'P&M tile lay' if could_do_pettibone?(entity)
          choices # .reject { |key, _| key == @round.tile_lay_mode }
        end

        def custom_tracker_available_hex(entity, hex, special_override: false)
          (special_override || tracker_available_hex(entity, hex)) &&
          (@round.tile_lay_mode != :brown_home || @game.home_hex_for(entity) == hex)
        end
      end
    end
  end
end
