# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G1846
      class Operating < Operating

        def select_entities
          corporations = @game.corporations.select(&:floated?)
          if @game.turn == 1 && @round_num == 1
            corporations.sort_by! do |c|
              sp = c.share_price
              [sp.price, sp.corporations.find_index(c)]
            end
          else
            corporations.sort!
          end
          @game.minors + corporations
        end
      end
    end
  end
end
