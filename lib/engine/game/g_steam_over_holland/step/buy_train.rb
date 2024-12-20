# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity != current_entity

            return %w[sell_shares buy_train] if must_sell_shares?(entity)
            return ['buy_train'] if can_afford_needed_train?(entity)
            return %w[buy_train pass] if can_close_corp?(entity) || can_buy_train?(entity)

            []
          end

          def pass_description
            if can_close_corp?(current_entity)
              "Close #{current_entity.name}"
            else
              @acted ? 'Done (Trains)' : 'Skip (Trains)'
            end
          end

          def process_pass(action)
            entity = action.entity

            if !@game.loading && can_afford_needed_train?(entity)
              raise GameError,
                    'Corporation can afford train, a train must be purchased.'
            end
            return super unless can_close_corp?(entity)

            @game.close_corporation(entity)
          end

          def process_sell_shares(action)
            bundle = action.bundle
            corporation = bundle.corporation
            old_price = corporation.share_price
            @game.share_pool.sell_shares(bundle)

            (bundle.num_shares - 1).times do
              @game.stock_market.move_left(corporation)
            end

            @game.log_share_price(corporation, old_price)
            @round.issued_shares[corporation] = true
          end

          def must_sell_shares?(corporation)
            return false if corporation.cash >= @game.depot.min_depot_price || !corporation.trains.empty?

            can_issue?(corporation) &&
              corporation.trains.empty?
          end

          def can_issue?(corporation)
            return false unless corporation.corporation?
            return false if @round.issued_shares[corporation]

            !@game.emergency_issuable_bundles(corporation).empty?
          end

          def should_buy_train?(entity)
            :close_corp if can_close_corp?(entity)
          end

          def can_close_corp?(entity)
            entity.trains.empty? &&
              !can_issue?(entity) &&
              entity.cash + entity.owner.cash < @game.depot.min_depot_price &&
              @game.graph.route_info(entity)&.dig(:route_train_purchase)
          end

          def can_afford_needed_train?(entity)
            entity.trains.empty? &&
              entity.cash + entity.owner.cash >= @game.depot.min_depot_price &&
              @game.graph.route_info(entity)&.dig(:route_train_purchase)
          end
        end
      end
    end
  end
end
