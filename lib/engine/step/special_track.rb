# frozen_string_literal: true

require_relative 'base'
require_relative 'tracker'

module Engine
  module Step
    class SpecialTrack < Base
      include Tracker

      ACTIONS = %w[lay_tile].freeze

      def actions(entity)
        return [] unless ability(entity)

        ACTIONS
      end

      def description
        "Lay Track for #{@company.name}"
      end

      def active_entities
        @company ? [@company] : super
      end

      def blocks?
        ability(@company)&.blocks
      end

      def process_lay_tile(action)
        if ability(action.entity)&.when == 'track' && !within_consecutive_lay?
          @game.game_error('Can only make extra tile lay as consecutive tile lay')
        end

        lay_tile(action)
        check_connect(action)
        ability(action.entity).use!
      end

      def available_hex(entity, hex)
        return unless ability(entity).hexes.include?(hex.id)

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def potential_tiles(entity, hex)
        return [] unless (tile_ability = ability(entity))

        tile_ability
          .tiles
          .map { |name| @game.tiles.find { |t| t.name == name } }
          .compact
          .select { |t| @game.phase.tiles.include?(t.color) && @game.upgrades_to?(hex.tile, t, tile_ability.special) }
      end

      def ability(entity)
        return unless entity&.company?

        ability = entity.abilities(:tile_lay, 'sold') if @round.respond_to?(:just_sold_company) &&
          entity == @round.just_sold_company
        ability || entity.abilities(:tile_lay, 'track')
      end

      def check_connect(action)
        company = action.entity
        tile_ability = ability(company)
        hex_ids = tile_ability.hexes
        return if !tile_ability&.connect || hex_ids.size < 2

        if company == @company
          paths = hex_ids.flat_map do |hex_id|
            @game.hex_by_id(hex_id).tile.paths
          end.uniq

          @game.game_error('Paths must be connected') if paths.size != paths[0].select(paths).size
        end

        @company = company
      end

      def setup
        @company = nil
      end

      private

      IGNORABLE_ACTIONS = %w[BuyCompany Pass].freeze

      def within_consecutive_lay?
        return true if @game.round.active_step.respond_to?(:process_lay_tile)

        unresolved_undo_actions = 0
        unresolved_redo_actions = 0
        @game.actions.reverse_each do |a|
          demodulized = demodulize(a)

          if demodulized == 'Redo'
            # Will skip previous undo
            unresolved_redo_actions += 1
            next
          end

          if demodulized == 'Undo'
            # This can either be canceled by a later Redo
            # or be a cancelation of a previous action
            if unresolved_redo_actions.positive?
              unresolved_redo_actions -= 1
            else
              unresolved_undo_actions += 1
            end
            next
          end

          if unresolved_undo_actions.positive?
            # This action was undone - ignore it
            unresolved_redo_actions -= 1
            next
          end

          if IGNORABLE_ACTIONS.include?(demodulized)
            # We can ignore this action as it does not really break
            # the consecutiveness of tile lay
            next
          end

          # Now we are down to the latest performed action
          return demodulized == 'LayTile'
        end
        false # Should never get here really
      end

      def demodulize(action)
        action.class.name.split('::').last
      end
    end
  end
end
