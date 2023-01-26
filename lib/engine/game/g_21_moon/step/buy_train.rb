# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G21Moon
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          MAX_BY_BASE = 2

          def actions(entity)
            return [] if entity.receivership?

            if entity == current_entity.owner
              return can_issue?(current_entity) ? [] : %w[sell_shares]
            end

            return [] unless entity.corporation?

            if must_buy_train?(entity)
              actions_ = %w[buy_train]
              actions_ << 'sell_shares' if can_issue?(entity)
              actions_
            elsif can_buy_train?(entity)
              %w[buy_train pass]
            else
              []
            end
          end

          def skip!
            if current_entity.corporation? && current_entity.receivership? && current_entity.trains.empty?
              receivership_buy!(current_entity)
              return
            end

            super
          end

          def receivership_buy!(entity)
            if entity.cash < @game.depot.min_depot_price
              pass!
              @log << "#{entity.name} is in receivership and cannot afford a train"
              @log << "#{entity.name} goes bankrupt"
              @game.close_corporation(entity)
              return
            end

            train = @game.depot.min_depot_train
            source = train.owner
            source_name = @depot.discarded.include?(train) ? 'The Discard' : train.owner.name
            price = train.price

            @log << "#{entity.name} (in receivership) buys a #{train.name} train for "\
                    "#{@game.format_currency(price)} from #{source_name}"

            @game.buy_train(entity, train, price)
            @game.phase.buying_train!(entity, train, source)
            @game.assign_base(train, :lb)
            pass!
          end

          # "issue" is a misnomer - it refers to any shares in a corp's treasury
          def can_issue?(entity)
            return false unless entity.corporation?

            issuable_shares(entity).any?
          end

          def issuable_shares(entity)
            return [] unless entity.corporation?

            @game.emergency_issuable_bundles(entity)
          end

          def setup
            super
            @destination_bases = []
          end

          def process_sell_shares(action)
            return issue_shares(action) if action.entity.corporation?

            if can_issue?(@round.current_entity)
              raise GameError, 'President may not sell shares while corporation can sell treasury shares.'
            end

            super
          end

          def issue_shares(action)
            corporation = action.entity
            bundle = action.bundle

            issuable = issuable_shares(corporation)
            bundle_index = issuable.index(bundle)

            raise GameError, "#{corporation.name} cannot sell share bundle: #{bundle.shares}" unless bundle_index

            @game.sell_shares_and_change_price(bundle)
          end

          def process_buy_train(action)
            base = action.slots.first.to_i.zero? ? :lb : :sp
            raise GameError, 'No room for LB train' if base == :lb && !room_for_lb?(action.entity)
            raise GameError, 'No room for SP train' if base == :sp && !room_for_sp?(action.entity)

            super
            @game.assign_base(action.train, base)
            @destination_bases << base
          end

          def room?(entity, _shell = nil)
            room_for_lb?(entity) || room_for_sp?(entity)
          end

          def room_for_lb?(entity)
            !@destination_bases.include?(:lb) && @game.lb_trains(entity).size < MAX_BY_BASE
          end

          def room_for_sp?(entity)
            !@destination_bases.include?(:sp) && @game.sp_trains(entity).size < MAX_BY_BASE
          end

          def slot_dropdown?(_corp)
            true
          end

          def slot_dropdown_title(_corp)
            'Select destination for purchased train:'
          end

          def slot_dropdown_options(corp)
            options = []
            options << { slot: 0, text: 'Local Base' } if room_for_lb?(corp)
            options << { slot: 1, text: 'Space Port Base' } if room_for_sp?(corp)
            options
          end

          def issue_text(_entity)
            'Emergency Corporate Sales:'
          end

          def issue_verb(_entity)
            'sell'
          end

          def must_issue_before_ebuy?(entity)
            can_issue?(entity)
          end

          def issue_corp_name(bundle)
            bundle.corporation.name
          end
        end
      end
    end
  end
end
