# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1858
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.minor?
            return [] if entity != current_entity

            actions = []
            actions << 'sell_shares' if ebuy_can_issue?(entity)
            actions << 'buy_train' if can_buy_train?(entity)
            actions << 'scrap_train' if can_scrap_train?(entity)
            actions << 'pass' unless actions.empty?
            actions
          end

          def scrappable_trains(entity)
            entity.trains.select(&:obsolete)
          end

          def scrap_info(_train)
            ''
          end

          def scrap_button_text(_train)
            'Scrap'
          end

          def process_scrap_train(action)
            train = action.train
            @log << "#{action.entity.name} discards wounded #{train.name} train"
            @game.remove_train(train)
            @depot.forget_train(train)
          end

          def president_may_contribute?(entity, _shell = nil)
            entity.trains.empty?
          end

          def ebuy_president_can_contribute?(corporation)
            corporation.cash < @game.depot.max_depot_price
          end

          def ebuy_can_issue?(entity)
            return false unless entity.corporation?
            return false unless can_buy_train?(entity)
            return false unless issuable_shares(entity).any?

            @depot.min_depot_price <= entity.cash + entity.owner.cash +
                                      issuable_shares(entity).map(&:price).max
          end

          def can_scrap_train?(entity)
            !scrappable_trains(entity).empty?
          end

          def pass_if_cannot_buy_train?(entity)
            !can_scrap_train?(entity)
          end

          def process_sell_shares(action)
            raise GameError, "#{entity.name} cannot sell shares at this time" unless action.entity.corporation?

            @last_share_issued_price = action.bundle.price_per_share
            @game.share_pool.sell_shares(action.bundle)
            old_price = action.entity.share_price
            @game.stock_market.move_left(action.entity)
            @game.log_share_price(action.entity, old_price)
          end

          def process_buy_train(action)
            if @last_share_issued_price && action.entity.trains.empty?
              raise GameError, 'Must buy a train from the train depot after issuing shares' unless action.train.from_depot?
              if (action.entity.cash - @last_share_issued_price) > action.price
                raise GameError, "More shares issued than needed to buy a #{action.variant} train"
              end
            end

            super
          end

          def pass!
            # A public company may be in the process of closing if emergency
            # money raising has pushed its share price to the bottom of the
            # market.
            closing = current_entity.share_price&.price&.zero?

            if @last_share_issued_price && current_entity.trains.empty? && !closing
              raise GameError, 'Must buy a train from the train depot after issuing shares'
            end

            super
            return if current_entity.minor?
            return if closing
            return unless current_entity.trains.empty?

            @log << "#{current_entity.name} does not own a train"
            old_price = current_entity.share_price
            @game.stock_market.move_left(current_entity)
            @game.log_share_price(current_entity, old_price)
          end

          def log_skip(entity)
            super unless entity.minor?
          end
        end
      end
    end
  end
end
