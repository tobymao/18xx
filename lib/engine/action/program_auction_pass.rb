# frozen_string_literal: true

require_relative 'program_enable'

module Engine
  module Action
    class ProgramAuctionPass < ProgramEnable
      def to_s
        'Pass in Auction Round until outbid'
      end

      def disable?(game)
        !game.round.auction?
      end
    end
  end
end
