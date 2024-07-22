# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity != current_entity

            return %w[buy_train sell_shares] if must_sell_shares?(entity)
            return %w[buy_train] if must_buy_train?(entity)

            if must_buy_train?(entity)
              actions_ = %w[buy_train]
              actions_ << 'sell_shares' if can_issue?(entity)
              actions_ << 'pass' if can_close?(entity)
              actions_
            elsif can_buy_train?(entity)
              %w[buy_train pass]
            else
              []
            end
          end

          def pass_description
            if current_entity.trains.empty?
              "Close #{current_entity.name}"
            else
              @acted ? 'Done (Trains)' : 'Skip (Trains)'
            end
          end

          def process_pass(action)
            entity = action.entity
            return super unless entity.trains.empty?

            @game.close_corporation(entity)
          end

          def must_sell_shares?(corporation)
            return false unless must_buy_train?(corporation)

            must_issue_before_ebuy?(corporation)
          end

          def must_issue_before_ebuy?(entity)
            can_issue?(entity)
          end

          def can_close?(entity)
            !can_issue?(entity) && @game.depot.min_depot_price > (entity.cash + entity.owner.cash)
          end

          def can_issue?(entity)
            return false unless entity.corporation?
            return false if @round.issued_shares
            return false unless @game.issuable_shares(entity).any?

            @game.issuable_shares(entity).any?
          end
        end
      end
    end
  end
end
