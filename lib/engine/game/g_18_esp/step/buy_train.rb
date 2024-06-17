# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18ESP
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(entity)
            # Cannot buy F train
            trains = super
            trains.reject! { |t| t.track_type == :narrow } if entity.type == :minor
            trains.reject! { |t| t.name == '2P' }
            trains.select!(&:from_depot?) unless @game.can_buy_trains
            trains
          end

          def buyable_train_variants(train, entity)
            trains = super

            trains.reject! { |v| type?(v[:name], :narrow) } if entity.type == :minor
            if @game.can_only_run_narrow?(entity) && entity.operatable_trains.empty?
              trains.reject! do |v|
                type?(v[:name], :broad)
              end
            end
            if @game.can_only_run_broad?(entity) && entity.operatable_trains.empty?
              trains.reject! do |v|
                type?(v[:name], :narrow)
              end
            end
            trains
          end

          def type?(name, type)
            (name.include?('+') && type == :narrow) || (!name.include?('+') && type == :broad)
          end

          def try_take_player_loan(entity, cost)
            return unless cost.positive?
            return unless cost > entity.cash

            raise GameError, "#{entity.name} already sold shares this round. Can not take loans" unless @corporations_sold.empty?

            difference = cost - entity.cash
            @game.take_player_loan(entity, difference)
          end

          def room?(entity, _shell = nil)
            entity.trains.count { |t| !@game.extra_train?(t) } < @game.train_limit(entity)
          end
        end
      end
    end
  end
end
