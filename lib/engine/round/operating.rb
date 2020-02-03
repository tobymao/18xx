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
          city = hex.tile.cities.find { |c| c.reservations.include?(corporation.sym.to_s) } || hex.tile.cities.first
          city.place_token(corporation)
        end
      end

      def finished?
        false
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
      end
    end
  end
end
