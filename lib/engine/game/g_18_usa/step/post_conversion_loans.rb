# frozen_string_literal: true

require_relative '../../g_1817/step/post_conversion_loans'
require_relative 'scrap_train_module'

module Engine
  module Game
    module G18USA
      module Step
        class PostConversionLoans < G1817::Step::PostConversionLoans
          include ScrapTrainModule
          def actions(entity)
            actions = super
            return actions if actions.empty?

            actions << 'scrap_train' if can_scrap_train?(entity)
            actions
          end
        end
      end
    end
  end
end
