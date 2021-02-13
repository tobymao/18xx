# frozen_string_literal: true

require_relative '../special_track'
require_relative '../track_lay_when_company_sold'

module Engine
  module Step
    module G1889
      class SpecialTrack < SpecialTrack
        include TrackLayWhenCompanySold

        def process_lay_tile(action)
          return super unless action.entity == @company

          entity = action.entity
          ability = @game.abilities(@company, :tile_lay, time: 'sold')
          raise GameError, "Not #{entity.name}'s turn: #{action.to_h}" unless entity == @company

          lay_tile(action, spender: @round.company_sellers[@company])
          check_connect(action, ability)
          ability.use!

          @company = nil
        end
      end
    end
  end
end
