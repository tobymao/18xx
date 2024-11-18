# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Norway
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            if entity == current_entity.owner
              return can_issue?(current_entity) ? [] : %w[sell_shares]
            end
            return [] unless entity.corporation?

            actions_ = []
            if must_buy_train?(entity)
              actions_ = %w[buy_train]
              actions_ << 'sell_shares' if can_issue?(entity)

            elsif can_buy_train?(entity)
              actions_ = %w[buy_train pass]
            end
            actions_
          end

          def cheapest_train_price(corporation)
            @game.cheapest_train_price(corporation)
          end

          def can_issue?(entity)
            return false unless entity.corporation?

            !issuable_shares(entity).empty?
          end

          def must_buy_train?(entity)
            return false if @game.abilities(entity, :ignore_mandatory_train) && !@game.phase.tiles.include?(:brown)

            entity.trains.none? { |train| !@game.ship?(train) }
          end

          def buyable_trains(entity)
            super.reject do |train|
              next false unless @game.ship?(train)

              must_buy_train?(entity) || entity.trains.any? { |ship| ship.name == train.name }
            end
          end

          def free_ship(corporation)
            ability = @game.abilities(corporation, :free_ship)
            return unless ability

            train = @depot.upcoming.find { |t| t.name == 'S3' }
            return unless train
            return if corporation.trains.any? { |t| t.name == 'S3' }

            @log << "#{corporation.name} receives a free S3 train"
            @game.buy_train(corporation, train, :free)
            @depot.remove_train(train)
            train.buyable = true
            train.reserved = true
            ability.use!
          end

          def add_ship_revenue(company)
            return if company.owner.nil?

            @game.bank.spend(10, company.owner)
            @game.log << "#{company.owner.name} receives #{@game.format_currency(10)} for building a ship"
          end

          def spend_minmax(entity, _train)
            [1, entity.cash]
          end

          def process_buy_train(action)
            super
            add_ship_revenue(@game.p4) if @game.ship?(action.train)
            free_ship(action.entity)
          end
        end
      end
    end
  end
end
