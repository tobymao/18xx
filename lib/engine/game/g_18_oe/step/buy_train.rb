# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative 'skip_abbreviated_round'

module Engine
  module Game
    module G18OE
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include SkipAbbreviatedRound

          def must_buy_train?(entity)
            entity.floated? && entity.trains.empty? && (!@game.fulfilled_train_obligation?(entity) || entity.type == :major)
          end

          def buyable_trains(entity)
            trains = super

            # Level 8 trains visible via available_on:'7+7' but gated until 4th L7 purchase (§11.6)
            trains = trains.reject { |t| t.name == '8+8' } unless @game.level8_train_available?

            return trains unless @game.train_obligation_active?

            if @game.fulfilled_train_obligation?(entity)
              return [] unless @game.non_starter_trains_available?

              trains.reject { |t| t.name == '2+2' }
            else
              trains.select { |t| t.name == '2+2' && t.from_depot? }
            end
          end

          def buyable_train_variants(train, entity)
            variants = super
            return variants unless train.owned_by_corporation?

            variants.select { |variant| variant[:name] == train.name }
          end

          def process_buy_train(action)
            if action.train.owned_by_corporation? && action.variant && action.variant != action.train.name
              raise GameError, 'A train purchased from another railroad must keep its current type'
            end

            reserved = action.train.name == '2+2' && action.train.from_depot?
            super
            @game.fulfill_train_obligation!(action.entity) if reserved
          end

          # TODO: Nationals claiming rusted trains for free (openpoints §1.9, §3.7) — deferred
        end
      end
    end
  end
end
