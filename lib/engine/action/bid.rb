# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class Bid < Base
      attr_reader :player, :company, :price

      def initialize(player, company, price)
        @player = player
        @company = company
        @price = price
      end

      def entity
        @player
      end

      def copy(game)
        self.class.new(
          game.player_by_name(@player.name),
          game.company_by_name(@company.name),
          @price,
        )
      end
    end
  end
end
