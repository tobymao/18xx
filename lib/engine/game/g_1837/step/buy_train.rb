# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1837
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            actions = super.clone
            if entity.operator? && !scrappable_trains(entity).empty?
              actions << 'pass' if actions.empty?
              actions << 'scrap_train'
            end
            actions.delete('pass') if must_buy_train?(entity)
            actions
          end

          def help
            return 'A train may only be surrendered in order to buy a new train' unless scrappable_trains(current_entity).empty?

            super
          end

          def ebuy_president_can_contribute?(corporation)
            super && president_may_contribute?(corporation)
          end

          def president_may_contribute?(entity, _shell = nil)
            !@must_buy_replacement &&
              !can_finance?(entity) &&
              (@game.can_buy_train_from_others? || @depot.depot_trains.map(&:price).max > entity.cash) &&
              super
          end

          def buyable_train_variants(train, entity)
            variants = super
            variants.select! { |t| @game.goods_train?(t[:name]) } if @game.coal_minor?(entity)
            variants
          end

          def other_trains(entity)
            return [] if can_finance?(entity)

            trains = super.reject { |t| t.owner.cash.negative? }
            trains.select! { |t| @game.goods_train?(t.name) } if @game.coal_minor?(entity)
            trains
          end

          def can_entity_buy_train?(_entity)
            true
          end

          def must_buy_train?(entity)
            return false unless entity.operator?

            @must_buy_replacement || super
          end

          def scrappable_trains(entity)
            return [] if @game.num_corp_trains(entity) < @game.train_limit(entity)

            min_train_purchase_price = @game.can_buy_train_from_others? ? 1 : @depot.min_depot_price
            entity.trains.select { |t| min_train_purchase_price + surrender_cost(t) <= entity.cash }
          end

          def surrender_cost(train)
            train.price / 2
          end

          def scrap_info(_train)
            ''
          end

          def scrap_button_text(train)
            "Surrender (#{@game.format_currency(-surrender_cost(train))})"
          end

          def scrap_header_text
            'Trains to Surrender'
          end

          def can_finance?(entity)
            entity.trains.empty? &&
              needed_cash(entity) > buying_power(entity) &&
              (entity.receivership? || @round.bankrupting_corporations.include?(entity))
          end

          def process_scrap_train(action)
            entity = action.entity
            train = action.train
            raise GameError, 'Can only scrap trains owned by the corporation' if entity != train.owner

            @log << "#{entity.name} spends #{@game.format_currency(surrender_cost(train))} to surrender" \
                    " a #{train.name} train to the bank"
            entity.spend(surrender_cost(train), @game.bank)
            @game.depot.reclaim_train(train)
            @must_buy_replacement = true
          end

          def process_buy_train(action)
            @must_buy_replacement = false
            super
            action.train.operated = true
          end

          def pass_if_cannot_buy_train?(entity)
            super && scrappable_trains(entity).empty?
          end

          def setup
            super
            @must_buy_replacement = false
          end
        end
      end
    end
  end
end
