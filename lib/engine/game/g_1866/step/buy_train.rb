# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1866
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def log_skip(entity)
            return if @game.national_corporation?(entity)

            @log << "#{entity.name} skips buy trains"
          end
        end
      end
    end
  end
end
