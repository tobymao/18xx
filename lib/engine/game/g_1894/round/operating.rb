# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1894
      module Round
        class Operating < Engine::Round::Operating
          def next_entity!
            hex = @game.saved_tokens_hex

            if hex
              hex.tile.cities.each do |c|
                c.remove_slot if c.tokens.size == 2 && c.tokens.compact.size != 2
              end
              @game.save_tokens(nil)
              @game.save_tokens_hex(nil)
            end

            super
          end
        end
      end
    end
  end
end