# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileLay < Base
      attr_reader :tiles, :free, :discount, :special, :connect, :blocks,
                  :reachable, :must_lay_together, :cost, :must_lay_all, :closed_when_used_up,
                  :consume_tile_lay, :laid_hexes, :lay_count, :upgrade_count, :combo_entities
      attr_accessor :hexes

      def setup(tiles:, hexes: nil, free: false, discount: nil, special: nil,
                connect: nil, blocks: nil, reachable: nil, must_lay_together: nil, cost: 0,
                closed_when_used_up: nil, must_lay_all: nil, consume_tile_lay: nil, lay_count: nil, upgrade_count: nil,
                combo_entities: nil)
        @hexes = hexes
        @tiles = tiles
        @free = free
        @discount = discount || 0
        @special = special.nil? ? true : special
        @connect = connect.nil? ? true : connect
        @closed_when_used_up = closed_when_used_up || false
        @blocks = !!blocks
        @reachable = !!reachable
        @must_lay_together = !!must_lay_together
        @must_lay_all = @must_lay_together && !!must_lay_all
        @cost = cost
        @consume_tile_lay = consume_tile_lay || false
        @laid_hexes = []

        @upgrade_count = upgrade_count
        @lay_count = lay_count
        @count ||= @lay_count
        @start_count = @count

        @combo_entities = combo_entities || []
      end

      def use!(upgrade: false)
        return if @count && !@count.positive?

        super

        return unless @upgrade_count
        return unless @lay_count

        if upgrade
          raise GameError, 'Cannot use this ability to upgrade a tile now' unless @upgrade_count.positive?

          @lay_count = 0
          @upgrade_count -= 1
          unless @upgrade_count.positive?
            owner.remove_ability(self)
            @count = 0
          end
        else
          raise GameError, 'Cannot use this ability to lay a tile now' unless @lay_count.positive?

          @upgrade_count = 0
          @lay_count -= 1
          unless @lay_count.positive?
            owner.remove_ability(self)
            @count = 0
          end
        end
      end
    end
  end
end
