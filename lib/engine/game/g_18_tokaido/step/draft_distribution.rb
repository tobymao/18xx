# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../g_18_los_angeles/step/draft_distribution'

module Engine
  module Game
    module G18Tokaido
      module Step
        class DraftDistribution < G18LosAngeles::Step::DraftDistribution
          def choose_company(player, company)
            super
            @game.after_buy_company(player, company, company.value)
          end
        end
      end
    end
  end
end
