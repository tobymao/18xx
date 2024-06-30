# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative 'emergency_assist'

module Engine
  module Game
    module G1841
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include EmergencyAssist

          def actions(entity)
            return [] unless can_entity_buy_train?(entity)
            return ['sell_shares'] if entity == current_entity&.player && can_ebuy_sell_shares?(current_entity)
            return [] if entity != current_entity
            return %w[buy_train sell_shares] if must_sell_shares?(entity)
            return %w[buy_train] if must_buy_train?(entity)
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def setup
            super
            @emr_triggered = false
          end

          def can_entity_buy_train?(entity)
            !@game.done_this_round[entity]
          end

          def must_sell_shares?(corporation)
            return false unless must_buy_train?(corporation)
            return false unless @game.emergency_cash_before_issuing(corporation) < @game.depot.min_depot_price

            must_issue_before_ebuy?(corporation)
          end

          def ebuy_president_can_contribute?(corporation)
            return false unless @game.emergency_cash_before_issuing(corporation) < @game.depot.min_depot_price

            !must_issue_before_ebuy?(corporation)
          end

          def president_may_contribute?(corporation)
            must_buy_train?(corporation) && ebuy_president_can_contribute?(corporation)
          end

          def issuable_shares(entity)
            return [] unless must_buy_train?(entity)

            super
          end

          def buyable_trains(entity)
            return super unless @emr_triggered

            [@game.depot.min_depot_train]
          end

          def train_variant_helper(train, _entity)
            variants = train.variants.values
            return variants if train.owned_by_corporation?

            variants
          end

          def can_sell?(_entity, bundle)
            @game.emr_can_sell?(current_entity, bundle)
          end

          def process_buy_train(action)
            entity = action.entity
            price = action.price
            player = entity.player

            if entity.cash < price && action.train.owner != @game.depot
              raise GameError, "#{entity.name} has insufficient cash to buy this train"
            end

            if @emr_triggered && action.train.owner != @game.depot
              raise GameError, 'Must purchase first train from depot after EMR'
            end

            if entity.cash < price && !must_buy_train?(entity)
              raise GameError, "#{entity.name} has #{@game.format_currency(entity.cash)} and cannot afford train"
            end

            if entity.cash < price && price > @game.depot.min_depot_price
              raise GameError, "#{entity.name} must buy cheapest train from bank"
            end

            # need to check this before sweeping owner's (or owner's owner's...) cash into corp
            if entity.cash < price && !issuable_shares(entity).empty?
              raise GameError, "#{entity.name} must sell shares before buying this train"
            end

            if entity.cash < price
              @emr_triggered = true
              sweep_cash(entity, player, price)

              if entity.cash < price
                raise GameError, "#{entity.name} has #{@game.format_currency(entity.cash)} and cannot afford train"
              end
            end

            super
            @emr_triggered = false
          end

          def track_action(action, corporation)
            @round.last_to_act = action.entity.player
            @round.current_actions << action
            @round.players_history[action.entity.player][corporation] << action
          end

          def process_sell_shares(action)
            seller = action.bundle.owner
            corp = action.bundle.corporation
            raise GameError, "Cannot sell shares of #{corp.name}" unless can_sell?(action.entity, action.bundle)
            raise GameError, 'Train puchase not required. Cannot sell shares' unless must_buy_train?(current_entity)

            @game.sell_shares_and_change_price(action.bundle, allow_president_change: @game.pres_change_ok?(corp))
            @game.update_frozen!
            @emr_triggered = true
            sweep_cash(current_entity, seller, @game.depot.min_depot_price)
            track_action(action, action.bundle.corporation)
            @round.recalculate_order if @round.respond_to?(:recalculate_order)
          end

          def issue_text(entity)
            bundles = issuable_shares(entity)
            owner = bundles&.first&.owner

            str = "#{owner.name} EMR Sell Shares"
            str += " (for #{entity.name})" if owner != entity
            str
          end

          def issue_verb(_entity)
            'sell'
          end

          def issue_corp_name(bundle)
            return 'IPO' if bundle.corporation == bundle.owner

            bundle.corporation.name
          end

          def real_owner(corp)
            corp.player
          end

          def corp_owner(corp)
            corp.player
          end

          def available_cash(corp)
            @game.emergency_cash_before_issuing(corp)
          end

          def available_cash_str(corp)
            str = @game.format_currency(corp.cash)
            avail = available_cash(corp)
            str += " (#{@game.format_currency(avail)} EMR cash is available)" if avail > corp.cash
            str
          end

          def issuing_corporation(corp)
            issuable_shares(corp).first&.owner || corp
          end

          def sellable_bundles(player, corp)
            bundles = @game.sellable_bundles(player, corp)
            bundles.each { |b| b.share_price = corp.share_price.price / 2.0 }
            bundles
          end
        end
      end
    end
  end
end
