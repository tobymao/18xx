# frozen_string_literal: true

require_relative '../../g_1849/step/token'

module Engine
  module Game
    module G1849Boot
      module Step
        class Token < G1849::Step::Token
          def process_place_token(action)
            entity = action.entity

            place_token(entity, action.city, action.token)

            index = @game.corporations.index { |c| c.name == 'SFR' }
            sfr = index ? @game.corporations[index] : nil
            if sfr && !sfr.floated? && @game.home_token_locations(sfr).empty?
              if sfr.next_to_par && sfr != @game.corporations.last
                @game.corporations[index + 1].next_to_par = true
                sfr.next_to_par = false
              end
              sfr.slot_open = false
              @game.corporations.delete(sfr)
              @game.corporations << sfr
              @log << 'sfr has no home token locations and cannot be opened until one becomes available.'
            end

            pass!
          end
        end
      end
    end
  end
end
