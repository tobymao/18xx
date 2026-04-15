# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18OE
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_entity_buy_train?(entity)
            return false unless entity.corporation?
            return false if entity.type == :minor

            true
          end

          # Detect phase 4/6/8 start and trigger national formation queue.
          def process_buy_train(action)
            before_phase = @game.phase.name
            super
            after_phase = @game.phase.name

            return unless before_phase != after_phase && %w[4 6 8].include?(after_phase)

            @game.trigger_nationals_formation!(action.entity.owner)
          end

          # Override buyable_trains to enforce:
          # (a) 2+2 obligation: only 2+2 available while corp has no trains and Phase < 4
          # (b) depot level gating: all trains at the cheapest level must sell out
          #     before the next level becomes available
          def buyable_trains(entity)
            trains = super

            # (a) 2+2 obligation window: only 2+2 purchasable
            return trains.select { |t| t.name == '2+2' } if entity.trains.empty? && @game.phase.name.to_i < 4

            # (b) depot level gating: filter to cheapest depot level only
            depot_trains = trains.select(&:from_depot?)
            unless depot_trains.empty?
              min_price = depot_trains.map(&:price).min
              trains = trains.reject { |t| t.from_depot? && t.price > min_price }
            end

            trains
          end

          # TODO: Nationals claiming rusted trains for free (openpoints §1.9, §3.7) — deferred
        end
      end
    end
  end
end
