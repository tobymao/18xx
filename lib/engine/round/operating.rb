# frozen_string_literal: true

require 'engine/action/lay_tile'

module Engine
  module Round
    class Operating < Base
      attr_reader :round_num

      def initialize(entities, hexes:, tiles:, companies:, bank:, round_num: 1) # rubocop:disable Metrics/ParameterLists
        super
        @round_num = round_num
        @hexes = hexes
        @tiles = tiles
        @companies = companies
        @bank = bank

        companies_payout
        place_home_stations
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
            queue = @hexes.select do |hex|
              hex.tile.cities.any? { |c| c.tokened_by?(current_entity) }
            end

            hexes = Hash.new { |h, k| h[k] = [] }

            queue.each { |hex| hexes[hex].concat((0..5).to_a) }

            until queue.empty?
              hex = queue.pop
              next unless (tile = hex.tile)

              tile.exits.each do |direction|
                neighbor = hex.neighbors[direction]
                queue << neighbor if neighbor && !hexes.key?(neighbor)
                hexes[neighbor] << Hex.invert(direction)
              end
            end

            hexes
          end
      end

      def legal_rotations(hex, tile)
        (0..5).select do |rotation|
          exits = tile.exits.map { |e| tile.rotate(e, rotation) }
          # connected to a legal route and not pointed into an offboard space
          (exits & layable_hexes[hex]).any? &&
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
          action.hex.lay(action.tile)
        when Action::PlaceToken
          action.city.place_token(action.entity)
        end
        @layable_hexes = nil
      end
    end
  end
end
