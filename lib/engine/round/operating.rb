# frozen_string_literal: true

require 'engine/action/lay_tile'
require 'engine/action/run_routes'
require 'engine/round/base'

module Engine
  module Round
    class Operating < Base
      attr_reader :phase, :round_num, :step

      STEPS = [
        :track,
        #:token,
        :route,
        :dividend,
        :train,
      ].freeze

      def initialize(entities, hexes:, tiles:, phase:, companies:, bank:, round_num: 1) # rubocop:disable Metrics/ParameterLists
        super
        @round_num = round_num
        @hexes = hexes
        @tiles = tiles
        @phase = phase
        @companies = companies
        @bank = bank
        @step = self.class::STEPS.first

        companies_payout
        place_home_stations
      end

      def next_entity
        current_index = self.class::STEPS.find_index(@step)
        if current_index < self.class::STEPS.size - 1
          @step = self.class::STEPS[current_index + 1]
          @current_entity
        else
          @step = self.class::STEPS.first
          super
        end
      end

      def companies_payout
        @companies.each do |company|
          @bank.spend(company.income, company.owner) if company.owner
        end
      end

      def place_home_stations
        @entities.each do |corporation|
          hex = @hexes.find { |h| h.coordinates == corporation.coordinates }
          city = hex.tile.cities.find { |c| c.reserved_by?(corporation) } || hex.tile.cities.first
          city.place_token(corporation)
        end
      end

      def layable_hexes
        @layable_hexes ||=
          begin
            # hexes is a map hex => exits
            hexes = Hash.new { |h, k| h[k] = [] }

            starting_hexes = @hexes.select do |hex|
              hex.tile.cities.any? { |c| c.tokened_by?(@current_entity) }
            end
            starting_hexes.each { |h| hexes[h] = h.tile.exits }

            queue = starting_hexes.dup

            until queue.empty?
              hex = queue.pop
              next unless hex.tile

              hexes[hex].each do |direction|
                next unless (neighbor = hex.neighbors[direction])

                queue << neighbor if !hexes.key?(neighbor) && hex.connected?(neighbor)
                hexes[neighbor] |= neighbor.connected_exits(hex) | [Hex.invert(direction)]
              end
            end

            starting_hexes.each { |h| hexes[h] |= h.neighbors.keys }

            hexes
          end
      end

      def legal_rotations(hex, tile)
        original_exits = hex.tile.exits

        (0..5).select do |rotation|
          exits = tile.exits.map { |e| tile.rotate(e, rotation) }
          # connected to a legal route and not pointed into an offboard space
          (exits & layable_hexes[hex]).any? &&
            ((original_exits & exits).size == original_exits.size) &&
            exits.all? { |direction| hex.neighbors[direction] }
        end
      end

      def finished?
        false
      end

      def operating?
        true
      end

      private

      def _process_action(action)
        case action
        when Action::LayTile
          @tiles.reject! { |t| action.tile.equal?(t) }
          action.tile.rotate!(action.rotation)
          action.hex.lay(action.tile)
        when Action::PlaceToken
          action.city.place_token(action.entity)
        when Action::RunRoutes
          action.routes.each do |route|
            @bank.spend(route.revenue, @current_entity.owner)
          end
        end
        @layable_hexes = nil
      end
    end
  end
end
