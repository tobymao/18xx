# frozen_string_literal: true

require_relative '../../g_1817/step/conversion'
require_relative 'scrap_train_module'
module Engine
  module Game
    module G18USA
      module Step
        class Conversion < G1817::Step::Conversion
          include ScrapTrainModule
          def actions(entity)
            actions = super
            actions << 'scrap_train' if can_scrap_train?(entity)
            actions
          end
        end
      end
    end
  end
end
