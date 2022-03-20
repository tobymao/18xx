# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1871
      module Step
        class BuySellParSplitShares < Engine::Step::BuySellParShares
          def actions(entity)
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity) || can_exchange_any?(entity)
            actions << 'par' if can_ipo_any?(entity)
            actions << 'split' if can_split_any?(entity)
            actions << 'sell_shares' if can_sell_any?(entity)

            actions << 'pass' unless actions.empty?
            actions
          end

          def process_buy_shares(action)
            super

            @round.bank_bought = true if action.purchase_for == @game.union_bank
          end

          def can_buy_for(entity)
            return [] unless entity == @game.company_by_id('UB').owner
            return [] if @round.bank_bought

            [@game.union_bank]
          end

          # This makes sure we don't auto pass if the player is allowed to
          # exchange a share
          def can_exchange_any?(entity)
            return false unless entity.player?

            entity.companies.each do |company|
              return true if %w[MC VR SB].include?(company.id)

              next unless company.id == 'IB'

              # Only true if there are shares available from an ipo'd company
              # that isn't PEIR, Mainline or Shortline
              corps = @game.corporations.select(&:ipoed).reject do |c|
                @game.mainline == c or @game.shortline == c or @game.peir == c
              end

              corps.each do |c|
                return true if @game.share_pool.shares_by_corporation[c].size.positive?
              end
            end

            false
          end

          def can_buy_shares?(entity, shares)
            return false if shares.empty?

            sample_share = shares.first
            corporation = sample_share.corporation
            owner = sample_share.owner
            return false if @round.players_sold[entity][corporation] || (bought? && !can_buy_multiple?(entity, corporation,
                                                                                                       owner))

            min_share = nil
            shares.each do |share|
              next unless share.buyable

              min_share = share if !min_share || share.percent < min_share.percent
            end

            bundle = min_share&.to_bundle
            return unless bundle

            cash = entity.cash

            bank_company = @game.company_by_id('UB')
            cash += @game.union_bank.cash if entity == bank_company.owner

            player_can_gain = can_gain?(entity, bundle)
            bank_can_gain = entity == bank_company.owner ? can_gain?(@game.union_bank, bundle) : false

            cash >= bundle.price && (player_can_gain || bank_can_gain)
          end

          # Since all shares start in the market we want to exclude any
          # non-ipoed shares from purchasable checks
          def can_buy_any_from_market?(entity)
            @game.share_pool.shares.group_by(&:corporation).each do |corporation, shares|
              next unless corporation.ipoed
              return true if can_buy_shares?(entity, shares)
            end

            false
          end

          def can_buy?(entity, bundle)
            return unless bundle&.buyable

            corporation = bundle.corporation
            cash = entity.cash

            if entity == @game.union_bank
              bank_company = @game.company_by_id('UB')
              cash += bank_company.owner.cash
            end

            cash >= bundle.price &&
              !@round.players_sold[entity][corporation] &&
              (can_buy_multiple?(entity, corporation, bundle.owner) || !bought?) &&
              can_gain?(entity, bundle)
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity
            return true if exchange

            super
          end

          def visible_corporations
            # Always show ML and SL
            @game.corporations[0..1].reject(&:closed?) +

              # Show ipoed
              @game.corporations[2..6].reject(&:closed?).select(&:ipoed) +
              (@game.tranch_available? ? @game.corporations[2..6].reject(&:closed?).reject(&:ipoed) : []) +

              # Only show Branches when ipoed
              @game.corporations[8..13].select(&:ipoed).reject(&:closed?) +

              # Always show the PEIR
              [@game.peir]
          end

          # On Prince Edward Island we par from the market
          def process_par(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, entity)

            @game.stock_market.set_par(corporation, share_price)
            share = @game.share_by_id("#{corporation.name}_0")
            buy_shares(entity, share.to_bundle)
            @game.after_par(corporation)
            track_action(action, action.corporation)
          end

          # Handle splits
          def process_split(action)
            corporation = action.corporation
            entity = action.entity
            raise GameError, "#{corporation.name} cannot be split" unless @game.can_split?(corporation, entity)

            # Set data needed for splitting
            @round.split_start(corporation)

            track_action(action, action.corporation)
          end

          # Check if we are allowed to split any of the current corporations
          def can_split_any?(entity)
            !bought? && @game.corporations.any? do |c|
              @game.can_split?(c, entity)
            end
          end

          # Ditto
          def can_ipo_any?(entity)
            !bought? && @game.corporations.any? do |c|
              @game.can_par?(c, entity) && can_buy?(entity, @game.share_by_id("#{c.name}_0")&.to_bundle)
            end
          end
        end
      end
    end
  end
end
