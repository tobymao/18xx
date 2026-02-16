# frozen_string_literal: true

require_relative '../../g_1880/step/buy_train'

module Engine
  module Game
    module G1880Romania
      module Step
        class BuyTrain < G1880::Step::BuyTrain
          def pass!
            train = @game.depot.upcoming.first
            train_name = train.name
            train_index = train.index

            return super if (train_name == '8' && train_index == 1) || %w[8E 2P].include?(train_name) || !discard_trains?

            discard_all_trains(train_name)
          end
        end
      end
    end
  end
end
