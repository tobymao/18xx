# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G1849
      class Token < Token
        def process_place_token(action)
          entity = action.entity

          place_token(entity, action.city, action.token)

          index = @game.corporations.index { |c| c.name == 'AFG' }
          afg = index ? @game.corporations[index] : nil
          if afg && !afg.floated? && @game.home_token_locations(afg).empty?
            if afg.next_to_par && afg != @game.corporations.last
              @game.corporations[index + 1].next_to_par = true
              afg.next_to_par = false
            end
            afg.slot_open = false
            @game.corporations.delete(afg)
            @game.corporations << afg
            @log << 'AFG has no home token locations and cannot be opened until one becomes available.'
          end

          pass!
        end
      end
    end
  end
end
