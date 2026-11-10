# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module GFrost1831
      module Round
        class Stock < Engine::Round::Stock
          protected

          def finish_round
            from = corporations_to_move_price.sort.to_h { |corporation| [corporation, corporation.share_price] }
            super
            from.each { |corporation, price| @game.share_price_changed(corporation, price) }
          end
        end
      end
    end
  end
end
