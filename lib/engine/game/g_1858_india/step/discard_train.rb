# frozen_string_literal: true

require_relative '../../g_1858/step/discard_train'

module Engine
  module Game
    module G1858India
      module Step
        class DiscardTrain < G1858::Step::DiscardTrain
          def trains(corporation)
            super.reject { |train| @game.mail_train?(train) }
          end
        end
      end
    end
  end
end
