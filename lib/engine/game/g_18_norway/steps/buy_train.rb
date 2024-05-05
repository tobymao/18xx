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
            entity.trains.none? { |train| !@game.ship?(train) }
          end

          def buyable_trains(entity)
            super.reject do |train|
              next false unless @game.ship?(train)
              
              must_buy_train?(entity) || entity.trains.any? { |ship| ship.name == train.name }
            end
          end

          def add_ship_revenue(company)
            return if company.owner.nil?

            @game.bank.spend(10, company.owner)
            @game.log << "#{company.owner.name} receives #{@game.format_currency(10)} for building a ship"
          end

          def process_buy_train(action)
            super
            add_ship_revenue(@game.p4) if @game.ship?(train)
          end
        end
      end
    end
  end
end
