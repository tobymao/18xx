# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1893
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity != current_entity
            # TODO: Not sure this is right
            return %w[sell_shares buy_train] if president_may_contribute?(entity)

            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def buyable_trains(entity)
            # Trains owned by minor cannot be bought by a corporation
            buyable = super.reject { |t| entity.corporation? && t.owner.minor? }

            # Can't buy trains from other minor or corporations in phase 1 and 2
            buyable.select!(&:from_depot?) unless @game.phase.status.include?('can_buy_trains')

            buyable
          end
        end
      end
    end
  end
end
