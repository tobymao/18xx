# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1840
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.minor?
            return [] if entity != current_entity
            return [] if entity.type == :city

            actions = []

            actions << 'scrap_train' unless scrappable_trains(entity).empty?
            return actions + %w[buy_train] if president_may_contribute?(entity)
            return actions + %w[buy_train pass] if can_buy_train?(entity)

            return actions if actions.empty?

            actions + %w[pass]
          end

          def buyable_train_variants(train, _entity)
            train.variants.values.select { |item| @game.available_trains.include?(item[:name]) }
          end

          def room?(entity, _shell = nil)
            scrappable_trains(entity).size < @game.train_limit(entity)
          end

          def scrappable_trains(entity)
            @game.scrappable_trains(entity)
          end

          def scrap_info(train)
            @game.scrap_info(train)
          end

          def scrap_button_text(_train)
            @game.scrap_button_text
          end

          def process_scrap_train(action)
            @game.scrap_train(action.train, action.entity)
          end

          def can_buy_train?(entity = nil, _shell = nil)
            entity ||= current_entity
            return false unless buyable_depot_trains?(entity)

            super
          end

          def must_buy_train?(entity)
            return false unless buyable_depot_trains?(entity)

            scrappable_trains(entity).size.zero?
          end

          def log_skip(entity)
            if !entity.minor? && entity.type != :city &&
               scrappable_trains(entity).empty? &&
               !buyable_depot_trains?(entity)
              @log << "#{entity.name}'s obligation to own a tram is temporarily lifted, because no trams are available."
              return
            end

            super
          end

          def must_take_player_loan?(corporation)
            price = cheapest_train_price(corporation)
            (@game.buying_power(corporation) + corporation.owner.cash) < price
          end

          def cheapest_train_price(corporation)
            cheapest_train = buyable_trains(corporation).min_by(&:price)
            cheapest_variant = buyable_train_variants(cheapest_train, corporation).first
            cheapest_variant[:price]
          end

          def process_buy_train(action)
            check_spend(action)
            buy_train_action(action)
          end

          def help
            'You can only assign one tram to a line'
          end

          def check_for_cheapest_train(train); end

          private

          def buyable_depot_trains?(entity)
            @depot.depot_trains.any? { |t| !buyable_train_variants(t, entity).empty? }
          end
        end
      end
    end
  end
end
