# frozen_string_literal: true

require_relative '../../../step/track_and_token'
require_relative 'receivership_skip'

module Engine
  module Game
    module G1833NE
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          include ReceivershipSkip

          def process_lay_tile(action)
            lay_tile_action(action)

            if action.entity == @game.lowell_merchants_company&.owner && @game.lowell_merchants_company_activated
              @game.remove_lowell_merchants_ability!
            end

            pass! if !can_lay_tile?(action.entity) && @tokened
          end
        end
      end
    end
  end
end
