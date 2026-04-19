# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18OE
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_entity_buy_train?(entity)
            entity.corporation? && entity.type != :minor
          end

          def must_buy_train?(entity)
            return false unless entity.trains.empty?
            return false unless @game.phase.status.include?('train_obligation')

            entity.floated?
          end

          # TODO: Nationals claiming rusted trains for free (openpoints §1.9, §3.7) — deferred
          # TODO: Reserved 2+2 obligation window (openpoints §3.1) — deferred
        end
      end
    end
  end
end
