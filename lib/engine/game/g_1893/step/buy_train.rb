# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1893
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_entity_buy_train?(_entity)
            true
          end

          def round_state
            super.merge(
              {
                discountable_trains_bought: [],
              }
            )
          end

          def discountable_trains_allowed?(entity)
            # A corporation/minor cannot do two discount buys during its turn
            !@round.discountable_trains_bought.include?(entity)
          end

          def buyable_trains(entity)
            # Trains owned by minor cannot be bought by a corporation
            buyable = super.reject { |t| entity.corporation? && t.owner.minor? }

            # Can't buy trains from other minor or corporations in phase 1 and 2
            buyable.select!(&:from_depot?) unless @game.phase.status.include?('can_buy_trains')

            buyable
          end

          def process_buy_train(action)
            entity ||= action.entity
            price = action.price
            train = action.train
            player = entity.player
            name = action.variant

            president_assist, _fee_amount = @game.president_assisted_buy(entity, train, price)

            if president_assist.positive?
              player.spend(president_assist, @game.bank)
              @game.bank.spend(president_assist, entity)
              assist = @game.format_currency(president_assist).to_s
              @log << "#{player.name} pays #{assist} to assist buying a #{name} train from The Depot"
            end

            super

            return unless action.exchange

            @round.discountable_trains_bought << action.entity
          end
        end
      end
    end
  end
end
