# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G18NY
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            actions = super
            return actions unless entity.corporation?
            return [] if entity.receivership?

            actions << 'scrap_train' unless scrappable_trains(entity).empty?
            actions << 'take_loan' if can_take_loan?(entity)
            actions << 'pass' unless actions.empty?
            if must_buy_train?(entity) || @round.active_train_loan || (@train_salvaged && entity.trains.empty?)
              actions.delete('pass')
              actions << 'buy_train'
            end
            actions.uniq
          end

          def ebuy_president_can_contribute?(corporation)
            super && president_may_contribute?(corporation)
          end

          def president_may_contribute?(entity, _shell = nil)
            super && !@train_salvaged
          end

          def scrappable_trains(entity)
            entity.trains
          end

          def scrap_info(_train)
            ''
          end

          def scrap_button_text(_train)
            'Salvage'
          end

          def can_take_loan?(entity)
            !can_afford_train?(entity) && entity.trains.empty? && !@train_salvaged && @game.can_take_loan?(entity)
          end

          def can_afford_train?(entity)
            entity.cash >= @game.depot.min_depot_price
          end

          def ebuy_offer_only_cheapest_depot_train?
            @round.active_train_loan
          end

          def needed_cash(_entity)
            @round.active_train_loan ? @depot.min_depot_price : @depot.max_depot_price
          end

          def round_state
            super.merge(
              {
                active_train_loan: false,
              }
            )
          end

          def setup
            super
            @train_salvaged = false
            @round.active_train_loan = false
          end

          def can_issue_shares?(entity)
            must_buy_train?(entity) && !@train_salvaged && entity.cash < @depot.max_depot_price
          end

          def issuable_shares(entity)
            # Issue is part of emergency buy
            return [] unless can_issue_shares?(entity)

            super
          end

          def selling_minimum_shares?(bundle)
            return true if bundle.owner&.corporation?

            super
          end

          def spend_minmax(entity, train)
            minmax = super
            minmax[0] = train.price if train.owner&.corporation? && !train.owner.loans.empty?
            minmax[-1] = train.price unless entity.loans.empty?
            minmax
          end

          def pass_if_cannot_buy_train?(entity)
            scrappable_trains(entity).empty?
          end

          def process_buy_train(action)
            train = action.train
            check_for_cheapest_train(train) if train.from_depot? && @round.active_train_loan

            super
          end

          def process_take_loan(action)
            @game.take_loan(action.entity)
            @round.active_train_loan = true
          end

          def process_scrap_train(action)
            raise GameError, 'Can only scrap trains owned by the corporation' if action.entity != action.train.owner

            @train_salvaged = true
            @game.salvage_train(action.train)
          end

          def help
            return if !@round.active_train_loan && !can_take_loan?(current_entity)

            'Once a loan is taken, a train must be purchased. Use the undo button to return the loans' \
              ' in order to pass without purchasing a train.'
          end
        end
      end
    end
  end
end
