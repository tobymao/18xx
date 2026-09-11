# frozen_string_literal: true

require 'view/game/program_auto_button'

module View
  module Game
    class AuctionAutoButton < ProgramAutoButton
      def program_action(entity)
        Engine::Action::ProgramAuctionPass.new(entity)
      end
    end
  end
end
