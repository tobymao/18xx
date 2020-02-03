# frozen_string_literal: true

require 'engine/action/lay_tile'

module Engine
  module Round
    class Operating < Base
      attr_reader :round_num

      def initialize(entities, tiles:, companies:, bank:, round_num: 1)
        super
        @round_num = round_num
        @tiles = tiles
        @companies = companies
        @bank = bank

        companies_payout
        place_home_stations
      end

      def companies_payout
        @companies.each do |company|
          company.owner.add_cash(company.income)
          @bank.remove_cash(company.income)
        end
      end

      def place_home_stations
        @entities.each do |corporation|
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
          action.city.place_token(action.entity, action.slot)
        end
      end
    end
  end
end
