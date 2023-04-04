# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1880
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def process_buy_train(action)
            @game.train_marker = action.entity if bought_trains?(action) && !@game.end_game_triggered
            @round.bought_trains = bought_trains?(action)
            super
          end

          def bought_trains?(action)
            @round.bought_trains || (action.train.owner == @game.depot && action.train.name != '2P')
          end

          def must_take_player_loan?(entity)
            @game.depot.min_depot_price > (entity.cash + entity.owner.cash)
          end

          def try_take_player_loan(entity, cost)
            return unless cost > entity.cash

            @game.take_player_loan(entity, cost - entity.cash)
          end

          def log_skip(entity)
            return if entity.minor?

            super
          end

          def round_state
            super.merge(
            { bought_trains: false }
          )
          end

          def pass!
            train_name = @game.depot.upcoming.first.name
            train_index = @game.depot.upcoming.first.index
            return super if (train_name == '8E' && train_index == 1) || %w[10 2P].include?(train_name) || !discard_trains?

            discard_all_trains(train_name)
          end

          def discard_trains?
            @game.train_marker == current_entity &&
            !@round.bought_trains &&
            @game.saved_or_round&.round_num != @round.round_num
          end

          def discard_all_trains(train_name)
            @game.log << "#{train_name} has not been bought for a full operating order, "\
                         "removing all remaining #{train_name} trains"
            @game.depot.export_all!(train_name, silent: true)
          end

          def setup
            super
            @round.bought_trains = false
          end

          def buyable_trains(entity)
            trains_to_buy = super
            trains_to_buy.reject! { |t| t.name == '2P' } unless can_buy_restored2?(entity)
            trains_to_buy.reject! { |t| t.name == '2P' && t.from_depot? } unless can_buy_restored2_from_depot?(entity)
            # Can't buy trains from other corporations until train 3
            return trains_to_buy if @game.can_cross_buy?

            trains_to_buy.select(&:from_depot?)
          end

          def owns_restored2?(entity)
            entity.trains.find { |t| t.name == '2P' }
          end

          def can_buy_restored2?(entity)
            @game.phase.available?(restored2_train&.available_on) &&
            !owns_restored2?(entity) &&
            @corporations_sold.empty?
          end

          def can_buy_restored2_from_depot?(entity)
            can_buy_restored2?(entity) && entity.cash >= restored2_train.price
          end

          def restored2_train
            @depot.depot_trains.find { |t| t.name == '2P' }
          end
        end
      end
    end
  end
end
