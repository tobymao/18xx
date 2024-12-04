# frozen_string_literal: true

require_relative '../../../step/train'

module Engine
  module Game
    module G1836Jr56
      module Train
        include Engine::Step::Train

        LAST_TRAINS = %w[2-4 3-3 4-2 5-1].freeze

        def buy_train_action(action, entity = nil, borrow_from: nil)
          train = action.train
          source = train.owner

          super

          @game.change_float if source == @game.depot && LAST_TRAINS.include?(train.id)
        end
      end
    end
  end
end
