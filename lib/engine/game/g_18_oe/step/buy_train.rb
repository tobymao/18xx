# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative 'skip_abbreviated_round'

module Engine
  module Game
    module G18OE
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include SkipAbbreviatedRound

          def actions(entity)
            actions = super - ['sell_shares']
            actions += ['choose'] if entity == current_entity && (forced_national?(entity) || insolvency?(entity))
            actions
          end

          def can_sell?(_entity, _bundle)
            false
          end

          def show_president_contributions?(entity, shell = nil)
            super && !forced_national?(entity) && !insolvency?(entity)
          end

          def forced_national?(entity)
            @game.forced_national_conversion?(entity)
          end

          def insolvency?(entity)
            @game.first_round_insolvency?(entity)
          end

          def choice_name
            entity = current_entity
            if insolvency?(entity)
              shortfall = @game.format_currency(@game.reserved_train_price - entity.cash - entity.owner.cash)
              return "#{entity.owner.name} cannot cover #{entity.name}'s #{shortfall} shortfall for its reserved " \
                     "#{@game.reserved_train_name}"
            end

            shortfall = @game.format_currency(@game.forced_train_price(entity) - entity.cash)
            "#{entity.owner.name} cannot cover #{entity.name}'s #{shortfall} shortfall for the cheapest train"
          end

          def choices
            return { @game.first_round_insolvency_choice => 'Declare first-round insolvency' } if insolvency?(current_entity)

            { @game.forced_national_choice => "Convert #{current_entity.name} to a national" }
          end

          def process_choose(action)
            entity = action.entity
            if action.choice == @game.first_round_insolvency_choice
              @game.declare_first_round_insolvency!(entity)
            elsif action.choice == @game.forced_national_choice
              raise GameError, "#{entity.name} cannot be converted to a national" unless forced_national?(entity)

              @game.force_national!(entity)
            else
              raise GameError, "Invalid choice: #{action.choice}"
            end
            pass!
          end

          def can_entity_buy_train?(entity)
            super && !@game.national?(entity)
          end

          def must_buy_train?(entity)
            return false if @game.national?(entity)

            entity.floated? && @game.trainless?(entity) && (!@game.fulfilled_train_obligation?(entity) || entity.type == :major)
          end

          def pass_if_cannot_buy_train?(entity)
            !must_buy_train?(entity)
          end

          def buyable_trains(entity)
            return [] if @game.national?(entity)

            trains = super.reject(&:rusted)
            trains = trains.reject { |t| @game.pullman?(t) && t.owned_by_corporation? } if cannot_afford_transfer?(entity)
            trains = trains.reject { |t| @game.pullman?(t) } if @game.pullman(entity)
            trains = trains.reject { |t| abandoned_minor_train?(t) }
            trains = trains.reject { |t| t.owned_by_corporation? && @game.national?(t.owner) }
            trains = trains.select { |t| @game.pullman?(t) } if at_train_limit?(entity)

            # Level 8 trains visible via available_on:'7+7' but gated until 4th L7 purchase (§11.6)
            trains = trains.reject { |t| t.name == '8+8' } unless @game.level8_train_available?

            return trains unless @game.train_obligation_active?

            if @game.fulfilled_train_obligation?(entity)
              return [] unless @game.non_starter_trains_available?

              trains.reject { |t| t.name == @game.reserved_train_name }
            else
              trains.select { |t| t.name == @game.reserved_train_name && t.from_depot? }
            end
          end

          def log_skip(entity)
            super unless @game.national?(entity)
          end

          def cannot_afford_transfer?(entity)
            entity.cash < @game.pullman_transfer_price
          end

          def room?(entity, _shell = nil)
            super || pullman_buyable?(entity)
          end

          def pullman_buyable?(entity)
            !@game.pullman(entity) && @depot.available(entity).any? { |t| @game.pullman?(t) && !abandoned_minor_train?(t) }
          end

          def abandoned_minor_train?(train)
            train.owned_by_corporation? && @game.abandoned_minor?(train.owner)
          end

          def at_train_limit?(entity)
            @game.num_corp_trains(entity) >= @game.train_limit(entity)
          end

          def spend_minmax(entity, train)
            return super if !@game.pullman?(train) || !train.owned_by_corporation?

            [@game.pullman_transfer_price] * 2
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

            train = action.train
            if @game.pullman?(train) && train.owned_by_corporation? && action.price != @game.pullman_transfer_price
              price = @game.format_currency(@game.pullman_transfer_price)
              raise GameError, "A Pullman from another railroad costs exactly #{price}"
            end
            if @game.pullman?(train) && @game.pullman(action.entity)
              raise GameError, "#{action.entity.name} already owns a Pullman"
            end
            raise GameError, "#{train.owner.name} is abandoned and its trains cannot be bought" if abandoned_minor_train?(train)
            if !@game.pullman?(train) && at_train_limit?(action.entity)
              raise GameError, "#{action.entity.name} has no room for another train"
            end

            reserved = train.name == @game.reserved_train_name && train.from_depot?
            royalty = @game.pullman?(train) && train.from_depot? && !@depot.discarded.include?(train)
            super
            @game.pay_pullman_royalty! if royalty
            @game.fulfill_train_obligation!(action.entity) if reserved
          end
        end
      end
    end
  end
end
