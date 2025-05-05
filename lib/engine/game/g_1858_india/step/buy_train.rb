# frozen_string_literal: true

require_relative '../../g_1858/step/buy_train'

module Engine
  module Game
    module G1858India
      module Step
        class BuyTrain < G1858::Step::BuyTrain
          def buyable_trains(entity)
            trains = super
            trains.reject! { |t| @game.mail_train?(t) } unless can_buy_mail_train?(entity)
            return trains unless at_train_limit?(entity)

            trains.select { |train| @game.mail_train?(train) }
          end

          private

          def can_buy_mail_train?(entity)
            !@game.owns_mail_train?(entity)
          end

          def room?(entity, _shell = nil)
            super || !@game.owns_mail_train?(entity)
          end

          def at_train_limit?(entity)
            @game.num_corp_trains(entity) == @game.train_limit(entity)
          end
        end
      end
    end
  end
end
