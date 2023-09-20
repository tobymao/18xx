# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G1844
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_train_variants(train, entity)
            variants = super
            variants.select! { |t| @game.hex_train_name?(t['name']) } if entity.type == :regional
            variants
          end
        end
      end
    end
  end
end
