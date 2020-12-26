# frozen_string_literal: true

require_relative '../discard_train'

module Engine
  module Step
    module G1828
      class DiscardTrain < DiscardTrain
        def round_state
          state = super || {}
          state[:ignore_train_limit] = false
          state
        end

        def crowded_corps
          return [] if @round.ignore_train_limit

          super.reject(&:system?)
        end
      end
    end
  end
end
