# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18Ireland
      module Round
        class Stock < Engine::Round::Stock
          def finish_round
            unless @minor_started
              first_minor = @game.corporations.find { |c| c.type == :minor && c.ipoed == false }
              if first_minor
                @game.log << "No minor started during stock round, closing #{first_minor.name}"
                @game.close_corporation(first_minor, quiet: true)
              end
            end
            super
          end

          def corporations_to_move_price
            @game.corporations.select(&:floated?)
          end
        end
      end
    end
  end
end
