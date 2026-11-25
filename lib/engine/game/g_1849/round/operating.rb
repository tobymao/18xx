# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1849
      module Round
        class Operating < Engine::Round::Operating
          def next_entity!
            return @game.end_game!(:stock_market) if @entities[@entity_index].reached_max_value

            super
          end

          def after_process(action)
            @game.close_afg_if_last_token_lost! if @game.pending_afg_closure
            super
          end
        end
      end
    end
  end
end
