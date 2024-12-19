# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1871
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] unless can_entity_buy_train?(entity)
            return ['sell_shares'] if (entity == current_entity&.owner || entity == @game.acting_for_entity(current_entity)) &&
                                      can_ebuy_sell_shares?(current_entity)
            return [] if entity != current_entity
            return %w[sell_shares buy_train] if president_may_contribute?(entity)
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def buyable_trains(entity)
            super.reject do |train|
              (entity.id == 'PEIR' && train.from_depot? && @round.bought_trains.include?(entity)) ||
              (@last_share_issued_price && !train.from_depot?)
            end
          end

          def buy_train_action(action, entity = nil)
            entity ||= action.entity
            acting = @game.acting_for_entity(entity.owner)
            borrow_from = if entity.owner != acting &&
                             entity.owner.cash < action.price &&
                             @game.liquidity(entity.owner, emergency: true) == entity.owner.cash
                            acting
                          end

            super(action, entity, borrow_from: borrow_from)
          end

          def process_buy_train(action)
            from_depot = action.train.from_depot?
            super
            return unless from_depot

            entity = action.entity
            @round.bought_trains << entity
            pass! if buyable_trains(entity).empty?
          end

          def round_state
            { bought_trains: [] }
          end

          # Override to allow companies to dump all of their treasury shares
          def can_sell?(entity, bundle)
            return false if entity != bundle.owner
            return false unless @game.check_sale_timing(entity, bundle)
            return false unless sellable_bundle?(bundle)
            return false if @game.class::MUST_SELL_IN_BLOCKS && @corporations_sold.include?(bundle.corporation)

            # This is our new clause for 1871, if this is the corporation
            # selling, we can sell all of them
            return true if bundle.corporation == bundle.owner

            # Corporations can sell all of their treasury shares during EMR,
            # players may never sell more than 30% of a corporation at once, even during EMR
            return false if bundle.percent > @game.class::TURN_SELL_LIMIT

            selling_minimum_shares?(bundle)
          end

          def process_sell_shares(action)
            super

            @last_share_issued_price = action.bundle.price_per_share if action.bundle.corporation == current_entity
          end
        end
      end
    end
  end
end
