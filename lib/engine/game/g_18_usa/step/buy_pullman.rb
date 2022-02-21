# frozen_string_literal: true

require_relative '../../../step/buy_train'
module Engine
  module Game
    module G18USA
      module Step
        class BuyPullman < Engine::Step::BuyTrain
          def description
            'Buy Pullman'
          end

          def pass_description
            'Skip (Pullman)'
          end

          def must_buy_train?(_)
            false
          end

          def president_may_contribute?(_)
            false
          end

          def can_buy_train?(entity, _shell = nil)
            @game.pullmans_available? && entity.runnable_trains.none? { |t| @game.pullman_train?(t) }
          end

          def buyable_trains(entity)
            # Can't buy a second pullman and can't buy a pullman if it's not legal to well, buy pullmans.
            return [] unless can_buy_train?(entity)

            # Cannot buy a pullman if you have a pullman
            (@depot.depot_trains & super).select { |t| @game.pullman_train?(t) }
          end
        end
      end
    end
  end
end
