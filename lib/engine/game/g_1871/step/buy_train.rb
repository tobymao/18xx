# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1871
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(entity)
            super.reject do |train|
              entity.id == 'PEIR' &&
              train.from_depot? &&
                @round.bought_trains.include?(entity)
            end
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
            return false unless @game.check_sale_timing(entity, bundle.corporation)
            return false unless sellable_bundle?(bundle)

            # This is our new clause for 1871, if this is the corporation
            # selling, we can sell all of them
            return true if bundle.corporation == bundle.owner

            selling_minimum_shares?(bundle)
          end
        end
      end
    end
  end
end
