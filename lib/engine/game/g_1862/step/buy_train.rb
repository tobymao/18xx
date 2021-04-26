# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1862
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          WARRANTY_COST = 50

          def actions(entity)
            return [] if entity != current_entity || buyable_trains(entity).empty?
            return [] if entity.share_price&.type == :close
            return %w[buy_train] if must_buy_train?(entity)

            super
          end

          def room?(entity, _shell = nil)
            if @game.phase.available?('G')
              entity.trains.size < @game.train_limit(entity)
            else
              entity.trains.empty? || room_for_any_type?(entity)
            end
          end

          def room_for_any_type?(entity)
            trains = entity.trains.group_by { |t| @game.train_type(t) }
            trains.keys.size < 3 || trains.values.any? { |v| v.size < @game.train_limit_by_type(entity) }
          end

          def room_for_type?(entity, type)
            trains = entity.trains.group_by { |t| @game.train_type(t) }
            (trains[type]&.size || 0) < @game.train_limit_by_type(entity)
          end

          def buyable_trains(entity)
            depot_trains = @depot.depot_trains
            other_trains = @depot.other_trains(entity)

            depot_trains = [@depot.min_depot_train] if entity.cash < @depot.min_depot_price

            other_trains.reject! { |t| entity.cash < @game.used_train_price(t) }
            other_trains.select! { |t| room_for_type?(entity, @game.train_type(t)) }

            depot_trains + other_trains
          end

          def buyable_train_variants(train, entity)
            return [] unless buyable_trains(entity).any? { |bt| bt.variants[bt.name] }

            variants = train.variants.values
            return variants if train.owned_by_corporation?

            variants.reject! { |v| v[:name] == train.sym }
            variants.select! { |v| room_for_type?(entity, @game.train_type_by_name(v[:name])) }
            variants
          end

          def check_spend(action)
            warranties = action.warranties || 0
            return unless action.entity.cash < action.price + (warranties * WARRANTY_COST)

            raise GameError "#{action.entity} cannot afford warranty cost of "\
              "#{@game.format_currency(warranties * WARRANTY_COST)}"
          end

          def buy_train_action(action)
            entity = action.entity
            train = action.train
            warranties = action.warranties || 0
            if warranties.positive?
              if warranties > warranty_limit(train)
                raise GameError "Can only purchase #{warranty_limit(train)} warranties for train"
              end

              entity.spend(warranties * WARRANTY_COST, @game.bank)
              suffix = warranties > 1 ? 'ies' : 'y'
              @log << "#{entity.name} pays #{@game.format_currency(warranties * WARRANTY_COST)} "\
                "for #{warranties} warrant#{suffix}"
            end

            super

            warranties.times { train.name = train.name + '*' }
          end

          def president_may_contribute?(_entity, _shell = nil)
            false
          end

          def fixed_price(train)
            @game.used_train_price(train)
          end

          def warranty_text
            'Warranties (each)'
          end

          def warranty_max
            warranty_limit(@depot.depot_trains.first)
          end

          def warranty_limit(train)
            if train.sym.include?('A') || train.sym.include?('D')
              2
            else
              3
            end
          end

          def warranty_cost
            @game.format_currency(WARRANTY_COST)
          end
        end
      end
    end
  end
end
