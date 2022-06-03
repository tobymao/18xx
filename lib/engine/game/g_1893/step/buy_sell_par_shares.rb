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
          EXCHANGE_ACTIONS = %w[buy_shares pass].freeze
          SELL_COMPANY_ACTIONS = %w[sell_company pass].freeze
          BUY_COMPANY_ACTIONS = %w[buy_corporation pass].freeze

          def actions(entity)
            return EXCHANGE_ACTIONS if entity == @game.fdsd && @game.rag.ipoed
            return [] unless entity&.player?
            return %w[assign pass] unless available_subsidiaries(entity).empty?
            return [] if first_sr_passed?(entity)

            result = super
            # This happens if a player can buy EVA from other player,
            # but nothing else - ignore that case and just skip player
            result = [] if result == %w[buy_company pass]

            result.concat(FIRST_SR_ACTIONS) if can_buy_company?(entity)
            result.concat(EXCHANGE_ACTIONS) if can_exchange?(entity)
            result.concat(SELL_COMPANY_ACTIONS) if can_sell_any_companies?(entity)
            result.concat(BUY_COMPANY_ACTIONS) if can_buy_company?(entity)
            result
          end

          def can_buy_company?(player, company = nil)
            return false if first_sr_passed?(player) || @game.num_certs(player) >= @game.cert_limit
            return buyable_company?(player, company) if company

            @game.buyable_bank_owned_companies.any? { |c| buyable_company?(player, c) }
          end

          def buyable_company?(player, company)
            return false if first_sr_passed?(player) || bought?
            return false if @game.bond?(company) && @round.players_sold[player][:bond]

            player.cash >= company.value
          end

          def can_sell_any_companies?(entity)
            return false if first_sr_passed?(entity)

            sellable_companies(entity).any? && !bought?
          end

          def can_sell_company?(company)
            @game.bond?(company)
          end

          def can_buy?(entity, bundle)
            return false if first_sr_passed?(entity)
            return false unless bundle
            return false unless @game.buyable?(bundle.corporation)
            return true if rag_exchangable(entity, bundle.corporation) && !bought?

            super
          end

          def can_sell?(entity, bundle)
            return false if first_sr_passed?(entity)
            return false unless bundle
            return false if @game.turn == 1

            super && @game.buyable?(bundle.corporation)
          end

          def can_gain?(entity, bundle, exchange: false)
            return false if first_sr_passed?(entity)
            return false unless bundle
            return false if exchange && !rag_exchangable(entity, bundle.corporation)

            super && @game.buyable?(bundle.corporation)
          end

          def can_exchange?(entity)
            return false if first_sr_passed?(entity)

            rag = @game.rag
            !bought? && exchange_ability(entity) && rag.num_market_shares.positive?
          end

          def ipo_type(corporation)
            return super if corporation != @game.agv && corporation != @game.hgk

            'Cannot be parred - formed via merge'
          end

          def first_sr_passed?(entity)
            @game.turn == 1 && @game.passers_first_stock_round.include?(entity)
          end

          def process_pass(action)
            @game.passers_first_stock_round << action.entity if @game.turn == 1
            super
          end

          def process_buy_company(action)
            company = action.company
            player = action.entity
            price = action.price

            handle_buy_company(company, player, price)

            @round.last_to_act = player
            @round.current_actions << action
          end

          def handle_buy_company(company, player, price)
            draft_object(company, player, price)
            @game.set_bond_names! if @game.bond?(company)
            return unless @game.draftables.one?

            @game.corporations.each do |c|
              next if @game.merged_corporation?(c)

              @game.remove_ability(c, :no_buy)
            end
          end

          def process_buy_corporation(action)
            company = action.minor
            player = action.entity
            price = action.price

            handle_buy_company(company, player, price)

            @round.last_to_act = player
            @round.current_actions << action
          end

          def process_sell_shares(action)
            player = action.entity
            corporation = action.bundle.corporation
            # In case president's share is reserved, do not change presidency
            allow_president_change = corporation.presidents_share.buyable
            @game.sell_shares_and_change_price(action.bundle,
                                               allow_president_change: allow_president_change,
                                               swap: action.swap)

            track_action(action, corporation, true)
            @round.players_sold[player][corporation] = :now
          end

          def process_sell_company(action)
            company = action.company
            player = action.entity
            price = action.price
            raise GameError, "Cannot sell #{company.id}" unless can_sell_company?(company)

            @game.set_bond_names! if @game.bond?(company)
            @log << "#{player.name} sells #{company.name} for #{@game.format_currency(price)} to the bank"
            @game.bank.spend(price, player)
            company.owner = @game.bank
            player.companies.delete(company)
            @round.players_sold[player][:bond] = :now if @game.bond?(company)

            @round.last_to_act = player
            @round.current_actions << action
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
            @game.close_fdsd
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
            track_action(action, action.corporation, true)

            @log << "Remaining 80% of #{corporation.name} is moved to market"
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

          def available_par_cash(entity, corporation, share_price: nil)
            available = entity.cash

            # If parring via FdSD, private can pay for 2 shares
            available += 2 * share_price.price if rag_exchangable(entity, corporation)

            available
          end

          def pass!
            if @par_rag
              @log << "#{@par_rag.entity.name} declines to exchange #{@game.fdsd.name}"
              return par_corporation(@par_rag)
            end

            # If FdSD owner passes in SR, and FdSD was to be closed
            # due to phase change, FdSD is forcibly closed
            @game.close_fdsd if @game.fdsd_to_close && @game.fdsd.player == @current_entity

            super
          end

          def process_buy_shares(action)
            entity = action.entity
            return exchange_for_rag(action, entity) if entity.company?

            # In case president's share is reserved, do not change presidency
            corporation = action.bundle.corporation
            allow_president_change = corporation.presidents_share.buyable
            buy_shares(action.entity, action.bundle, swap: action.swap, allow_president_change: allow_president_change)
            track_action(action, corporation, true)

            # If FdSD owner buys something in SR, and FdSD was to be closed
            # due to phase change, FdSD is forcibly closed
            @game.close_fdsd if @game.fdsd_to_close && @game.fdsd.player == entity
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
            @game.close_fdsd

            @game.share_pool.buy_shares(player,
                                        bundle,
                                        exchange: true, # Will not log anything
                                        exchange_price: 0,
                                        allow_president_change: true)

            track_action(action, corporation, true)
          end

          def description
            return 'Exchange FdSD' unless available_subsidiaries(current_entity).empty?

            super
          end

          def pass_description
            return 'Pass (Exchange FdSD)' unless available_subsidiaries(current_entity).empty?

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

          def sellable_companies(entity)
            return [] unless @game.turn > 1
            return [] unless entity.player?

            entity.companies.select { |c| @game.bond?(c) }
          end

          def sell_price(company)
            company.value
          end

          # Override this to let auto buy always buy from market
          # as there are no shares in IPO after parring
          def from_market?(_program)
            true
          end

          def purchasable_companies(entity = nil)
            entity ||= @game.current_entity
            @game.purchasable_companies(entity)
          end
        end
      end
    end
  end
end
