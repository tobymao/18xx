# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def room?(entity)
            room = @game.num_corp_trains(entity) < @game.train_limit(entity)
            return true if room

            # even when train tight, there's room for a self-rust
            return true if entity.trains.any? { |t| t.rusts_on == @game.depot.upcoming[0].name }
          end
        end
      end
    end
  end
end
