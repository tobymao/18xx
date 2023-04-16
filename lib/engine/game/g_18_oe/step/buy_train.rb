# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18OE
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_entity_buy_train?(_entity)
            true
          end

          # This will also have logic for when you can buy trains
          # Such as 3 trains being available after the first OR and after all minors/regionals have floated (major phase)
          # And nationals getting rusted trains
        end
      end
    end
  end
end
