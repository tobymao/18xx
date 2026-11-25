# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/train'
require_relative 'skip_abbreviated_round'

module Engine
  module Game
    module G18OE
      module Step
        class NationalBuyTrains < Engine::Step::Base
          include Engine::Step::Train
          include SkipAbbreviatedRound

          def round_state
            { national_upgraded: false }
          end

          def setup
            super
            @round.national_upgraded = false
          end

          def actions(entity)
            return [] if skip?
            return [] if entity != current_entity || !@game.national?(entity)

            can_buy_train?(entity) ? %w[buy_train pass] : []
          end

          def description
            'Buy Trains'
          end

          def pass_description
            @acted ? 'Done (Trains)' : 'Skip (Trains)'
          end

          def log_skip(entity)
            super if @game.national?(entity)
          end

          def can_entity_buy_train?(entity)
            @game.national?(entity)
          end

          def must_buy_train?(_entity)
            false
          end

          def president_may_contribute?(_entity, _shell = nil)
            false
          end

          def discountable_trains_allowed?(_entity)
            true
          end

          def buyable_trains(entity)
            return [] if !@game.national_swaps_open? || !room?(entity)

            @game.national_claimable_trains
          end

          def can_buy_train?(entity = nil, _shell = nil)
            entity ||= current_entity
            !buyable_trains(entity).empty? || !@game.discountable_trains_for(entity).empty?
          end

          def process_buy_train(action)
            entity = action.entity
            train = action.train
            exchange = action.exchange
            raise GameError, 'Nationals acquire trains for free' unless action.price.zero?

            variant = action.variant || train.name
            if exchange
              process_exchange(entity, train, exchange, variant)
            else
              claim(entity, train, variant)
            end
            pass! unless can_buy_train?(entity)
          end

          private

          def claim(entity, train, variant)
            check_rusted_available!(train)
            raise GameError, 'Locomotive Works claims are closed after an upgrade' unless @game.national_swaps_open?
            raise GameError, "#{entity.name} has no room for another train" unless room?(entity)
            raise GameError, "#{variant} is not a variant of #{train.name}" unless train.variants.key?(variant)

            @game.national_claim_train!(entity, train, variant)
          end

          def process_exchange(entity, train, exchange, variant)
            owned_rusted = exchange.owner == entity && exchange.rusted
            raise GameError, "#{exchange.name} is not a rusted train of #{entity.name}" unless owned_rusted

            if train.rusted
              swap(entity, train, exchange, variant)
            else
              upgrade(entity, train, exchange, variant)
            end
          end

          def swap(entity, train, exchange, variant)
            check_rusted_available!(train)
            raise GameError, 'Locomotive Works exchanges are closed after an upgrade' unless @game.national_swaps_open?
            raise GameError, "#{train.name} is not a higher level train than #{exchange.name}" unless train.level > exchange.level
            raise GameError, "#{variant} is not a variant of #{train.name}" unless train.variants.key?(variant)

            @game.national_swap_train!(entity, exchange, train, variant)
          end

          def upgrade(entity, train, exchange, variant)
            allowed = @game.national_upgrade_trains(entity).include?(train) && variant == train.name
            raise GameError, "#{train.name} cannot be taken in an upgrade by #{entity.name}" unless allowed

            @game.national_upgrade_train!(entity, exchange, train)
            @round.national_upgraded = true
          end

          def check_rusted_available!(train)
            in_works = train.rusted && @game.rusted_trains.include?(train)
            raise GameError, "#{train.name} is not in the Locomotive Works" unless in_works
          end
        end
      end
    end
  end
end
