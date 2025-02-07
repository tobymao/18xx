# frozen_string_literal: true

require_relative '../../g_1858/step/buy_train'

module Engine
  module Game
    module G1858India
      module Step
        class BuyTrain < G1858::Step::BuyTrain
          def buyable_trains(entity)
            return super unless @game.owns_mail_train?(entity)

            super.reject { |train| @game.mail_train?(train) }
          end
        end
      end
    end
  end
end
