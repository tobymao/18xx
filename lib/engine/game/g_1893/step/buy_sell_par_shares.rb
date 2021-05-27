# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'buy_minor'

module Engine
  module Game
    module G1893
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include BuyMinor

          FIRST_SR_ACTIONS = %w[buy_company pass].freeze
          EXCHANGE_ACTIONS = %w[buy_shares].freeze

          def actions(entity)
            return EXCHANGE_ACTIONS if entity == @game.fdsd && @game.rag.ipoed
            return [] unless entity&.player?

            return %w[assign pass] unless available_subsidiaries(entity).empty?

            result = super
            result.concat(FIRST_SR_ACTIONS) if can_buy_company?(entity)
            result << 'buy_shares' if exchange_ability(entity) && !bought? && !first_sr_passed?(entity)
            result
          end

          def can_buy_company?(player, _company = nil)
            return false if first_sr_passed?(player)

            @game.buyable_companies.any? { |c| player.cash >= c.value } && !sold? && !bought?
          end

          def can_buy?(entity, bundle)
            return false if first_sr_passed?(entity) || !@game.buyable?(bundle.corporation)
            return true if rag_exchangable(entity, bundle.corporation) && !bought?

            super
          end

          def can_sell?(_entity, bundle)
            return false if @game.turn == 1
            return !bought? if bundle.corporation == @game.adsk

            super && @game.buyable?(bundle.corporation)
          end

          def can_gain?(entity, bundle, exchange: false)
            return false if exchange && !rag_exchangable(entity, bundle)

            !first_sr_passed?(entity) && super && @game.buyable?(bundle.corporation)
          end

          def can_exchange?(entity)
            rag = @game.rag
            !bought? && exchange_ability(entity) && rag.ipoed && rag.num_market_shares.positive?
          end

          def ipo_type(corporation)
            return super if corporation != @game.agv && corporation != @game.hgk

            'Cannot be parred - formed via merge'
          end

          def first_sr_passed?(entity)
            @game.passers_first_stock_round.include?(entity)
          end

          def process_pass(action)
            @game.passers_first_stock_round << action.entity if @game.turn == 1
            super
          end

          def process_buy_company(action)
            entity = action.entity
            company = action.company
            price = action.price

            super

            if @game.buyable_companies.one?
              @game.corporations.each do |c|
                next if @game.merged_corporation?(c)

                @game.remove_ability(c, :no_buy)
              end
            end

            @round.last_to_act = entity

            handle_connected_minor(company, entity, price)
          end

          def process_sell_shares(action)
            # In case president's share is reserved, do not change presidency
            allow_president_change = action.bundle.corporation.presidents_share.buyable
            @game.sell_shares_and_change_price(action.bundle,
                                               allow_president_change: allow_president_change,
                                               swap: action.swap)

            track_action(action, action.bundle.corporation)
          end

          def process_par(action)
            corporation = action.corporation
            @par_rag = (action if rag_exchangable(action.entity, corporation))

            return par_corporation(action) if available_subsidiaries(current_entity).empty?

            # If player cannot afford to par without exchange, make automatic exchange
            player = action.entity
            return process_assign(nil) if player.cash < action.share_price.price * 2

            # Need to ask player if exchange should be done
            @log << "#{player.name} may pay for par by exchanging #{@game.fdsd.name}"
          end

          def process_assign(_action)
            player = @par_rag.entity
            rag = @par_rag.corporation

            @log << "#{player.name} exchanges #{@game.fdsd.name} to pay for par of #{rag.name}"
            close_fdsd
            @game.bank.spend(@par_rag.share_price.price * 2, player)

            par_corporation(@par_rag)
            @par_rag = nil
          end

          def par_corporation(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, entity)

            @game.stock_market.set_par(corporation, share_price)
            share = corporation.ipo_shares.first
            buy_shares(entity, share.to_bundle)
            @game.after_par(corporation)
            track_action(action, action.corporation)

            @log << "Remaining 80% of #{corporation.name} are moved to market"
            @game.move_buyable_shares_to_market(corporation)
            @par_rag = nil
          end

          def get_par_prices(entity, corporation)
            # If parring RAG and owning FdSD, any par price can be used
            par_prices = if rag_exchangable(entity, corporation)
                           @game.stock_market.par_prices
                         else
                           super
                         end

            # Exclude 120 par - these are just starts for AGV/HGK
            par_prices.reject { |p| p.price == 120 }
          end

          def available_par_cash(entity, corporation, _share_price)
            available = entity.cash

            # If parring at max (100), FdSD private can pay for 200
            available += 200 if rag_exchangable(entity, corporation)

            available
          end

          def pass!
            if @par_rag
              @log << "#{@par_rag.entity.name} declines to exchange #{@game.fdsd.name}"
              return par_corporation(@par_rag)
            end

            # If FdSD owner passes in SR, and FdSD was to be closed
            # due to phase change, FdSD is forcibly closed
            if @game.fdsd_to_close && @game.fdsd.player == @current_entity
              close_fdsd
              @game.fdsd_to_close = false
            end

            super
          end

          def process_buy_shares(action)
            entity = action.entity
            return exchange_for_rag(action, entity) if entity.company?

            # In case president's share is reserved, do not change presidency
            corporation = action.bundle.corporation
            allow_president_change = corporation.presidents_share.buyable
            buy_shares(action.entity, action.bundle, swap: action.swap, allow_president_change: allow_president_change)
            track_action(action, corporation)
            @round.last_to_act = action.entity
            @round.current_actions << action
          end

          def exchange_for_rag(action, entity)
            player = entity.player
            bundle = action.bundle
            corporation = bundle.corporation

            if corporation.num_market_shares > 1
              # Exchange for a 20% bundle instead
              bundle_20_percent = nil
              @game.bundles_for_corporation(@game.share_pool, corporation).each do |b|
                bundle_20_percent = b if !bundle_20_percent && b.num_shares == 2
              end
              bundle = bundle_20_percent if bundle_20_percent
            end

            share_str = bundle.num_shares == 1 ? ' the last 10% share ' : ' two 10% shares '
            share_str += "of #{corporation.name}"
            @log << "#{player.name} exchanges #{@game.fdsd.name} for #{share_str} from market"
            close_fdsd

            @game.share_pool.buy_shares(player,
                                        bundle,
                                        exchange: true, # Will not log anything
                                        exchange_price: 0,
                                        allow_president_change: true)

            track_action(action, corporation)
            @round.last_to_act = player
            @round.current_actions << action
          end

          def description
            return 'Exchange FdSD' unless available_subsidiaries(current_entity).empty?

            super
          end

          def pass_description
            return 'Pass (Exchange FsDF)' unless available_subsidiaries(current_entity).empty?

            super
          end

          def log_pass(entity)
            return unless available_subsidiaries(current_entity).empty?

            super
          end

          def available_subsidiaries(entity)
            entity ||= current_entity
            return [] unless @par_rag&.entity == entity

            fdsd = exchange_ability(entity.owner)
            fdsd ? [fdsd] : nil
          end

          def exchange_ability(player)
            fdsd = @game.fdsd
            return if !fdsd || fdsd.closed? || fdsd.owner != player

            fdsd
          end

          def rag_exchangable(player, corporation)
            corporation == @game.rag && exchange_ability(player)
          end

          # When parring RAG and owning FdSD private,
          # FdSD and RAG are only shown while selecting if exchange
          # of FdSD should be done
          def visible_corporations
            if @par_rag
              @game.sorted_corporations.select { |c| c == @game.rag }
            else
              @game.sorted_corporations.reject(&:closed?)
            end
          end

          def close_fdsd
            fdsd = @game.fdsd
            fdsd.close!
            @log << "#{fdsd.name} closed"
          end
        end
      end
    end
  end
end
