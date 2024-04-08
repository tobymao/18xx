# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/share_buying'

# For 18 India, first turn is only sell any, subsequent turns are only buy
# Selling does not restrict buy actions
# NOTE: This section isn't completed, in progress for stock round
# TODO: Convert Bonds -> add ability to bonds
module Engine
  module Game
    module G18India
      module Step
        class SellOnceThenBuyCerts < Engine::Step::BuySellParShares
          include Engine::Step::ShareBuying

          def debugging_log(str)
            LOGGER.debug(str)
            LOGGER.debug " stock_turns: #{@round.stock_turns} - selling_round: #{selling_round?} - @game.turn: #{@game.turn}"
            LOGGER.debug " pass_order: #{@round.pass_order} - last_to_act: #{@round.last_to_act}"
            LOGGER.debug " Cert Limit: #{@game.cert_limit(current_entity)} - Num Certs: #{@game.num_certs(current_entity)}"
            LOGGER.debug " buyable companies: #{buyable_companies(current_entity).map(&:name).join(', ')}"
          end

          def debug_corp_log(share, str = '')
            corp = share.corporation
            p_s = corp.presidents_share
            LOGGER.debug(str)
            LOGGER.debug "> share: #{share.id} / owner: #{share.owner.name} / corp: #{corp}"
            LOGGER.debug "> corp owner: #{corp.owner ? corp.owner.name : 'nil'} / PS owner: #{p_s.owner.name} at #{p_s.percent}%"
            LOGGER.debug "> floated: #{corp.floated} / iposhares #{corp.ipo_shares}"
            LOGGER.debug "> #{current_entity&.name} shares: #{current_entity.shares.select { |s| s.corporation == corp }}"
          end

          def log_pass(entity)
            return @log << "#{entity.name} passes" if @round.current_actions.empty?
            return if bought? && sold?

            action = selling_round? ? 'to sell' : 'to buy'
            @log << "#{entity.name} declines #{action} shares"
          end

          def setup
            super
            @round.stock_turns += 1
            @round.bought_from_market = false
            @round.bought_from_hand = false
          end

          def round_state
            super.merge({ stock_turns: 0, bought_from_market: false, bought_from_hand: false })
          end

          def selling_round?
            return false if @game.turn == 1 # no selling during first SR

            @round.stock_turns <= @round.entities.size # each player gets one selling round
          end

          def description
            if selling_round?
              if must_sell?(current_entity)
                'Sell Certificates (MUST SELL below cert limit)'
              else
                'Sell Certificates (only opportunity to sell in Stock Round)'
              end
            else
              'Buy Certificates'
            end
          end

          def pass_description
            if @round.current_actions.empty?
              'Pass (Certificates)'
            else
              'Done (Certificates)'
            end
          end

          # Test showing bank certs / companies at top before corporations in stock view
          def bank_first?
            true
          end

          def actions(entity)
            return [] unless entity == current_entity

            actions = []
            if selling_round?
              # sell anything, only limitation is president share can't be in market
              # NOTE: GIPR President share CAN be in market [TODO]
              actions << 'sell_shares' if can_sell_any?(entity)
              actions << 'sell_company' if can_sell_any_companies?(entity)
            else
              # buy 1 share from market [ok]
              # buy 1 or 2 shares from same IPO row [ok]
              # buy 1 or mort matching certs from player hand [ok]
              # buy 1 private company from bank [ok]
              # buy 1 railroad bond [prevent spaming all 10 copies]
              # convert BOND into GIPR share (Phase IV) [TODO]
              actions << 'buy_shares' if can_buy_any?(entity)
              actions << 'buy_company' if can_buy_any_companies?(entity)
            end
            actions << 'pass' unless actions.empty?
            actions.delete('pass') if must_sell?(entity) && selling_round? # may not pass during selling round if "must_sell"
            actions
          end

          # ------ Code for tracking purchases ------

          def buying_proxy?
            @round.bought_from_hand || @round.bought_from_ipo
          end

          # ------ Code for 'buy_company' Action ------

          # Modify to track ability to buy companies (mulitple buy from same IPO row and matching Player Hands)
          def can_buy_any_companies?(entity)
            return false if @round.bought_from_market

            buyable_companies(entity).count.positive?
          end

          def buyable_companies(entity)
            return [] unless entity.player?

            companies = []
            companies += @game.bank_owned_companies.select { |c| can_buy_from_market?(entity, c) }
            companies += @game.top_of_ipo_rows.select { |c| can_buy_from_ipo?(entity, c) }
            companies += current_entity.hand.select { |c| can_buy_from_hand?(entity, c) }

            companies
          end

          def can_buy_company?(entity, company)
            return false if @round.bought_from_market
            return false if @game.bank_owned_companies.include?(company) && !can_buy_from_market?(entity, company)
            return false if @game.in_ipo?(company) && !can_buy_from_ipo?(entity, company)
            return false if current_entity.hand.include?(company) && !can_buy_from_hand?(entity, company)

            (available_cash(entity) >= company.value)
          end

          def can_buy_from_market?(entity, company)
            return false if @round.bought_from_market || @round.bought_from_ipo || @round.bought_from_hand

            if @game.num_certs(entity) >= @game.cert_limit(entity) && company.type != :bond
              return false # bonds do not count for cert limit
            end

            (available_cash(entity) >= company.value)
          end

          def can_buy_from_hand?(entity, company)
            return false if @round.bought_from_market
            return false if @round.bought_from_ipo
            return false if @game.num_certs(entity) >= @game.cert_limit(entity)

            if @round.bought_from_hand
              prior = @round.bought_from_hand
              if prior.type == :private
                company.type == :private
              else
                prior.name == company.name
              end
            else
              (available_cash(entity) >= company.value)
            end
          end

          def can_buy_from_ipo?(entity, company)
            return false if @round.bought_from_market
            return false if @round.bought_from_hand
            return false if @round.bought_from_ipo && @round.current_actions.count > 1
            return false if @game.num_certs(entity) >= @game.cert_limit(entity)

            row, index = @game.ipo_row_and_index(company)
            if @round.bought_from_ipo
              (@round.bought_from_ipo == row) && index.zero? && (available_cash(entity) >= company.value)
            else
              index.zero? && (available_cash(entity) >= company.value)
            end
          end

          # Separates share proxies from companies, track location of poxy when bought
          def process_buy_company(action)
            entity = action.entity
            company = action.company
            price = action.price
            owner = company.owner

            raise GameError, "Cannot buy #{company.name} from #{owner.name}" if owner&.corporation?

            track_action(action, company)

            if @game.in_ipo?(company)
              row, _index = @game.ipo_row_and_index(company)
              location = 'IPO Row: ' + (row + 1).to_s
              @game.ipo_remove(row, company)
              @round.bought_from_ipo = row
            elsif owner == @game.bank
              location = 'the Bank'
              @game.bank.companies.delete(company)
              @round.bought_from_market = true
            else
              location = 'their Draft Hand'
              @game.remove_from_hand(current_entity, company)
              @round.bought_from_hand = company
            end

            case company.type
            when :share
              share = company.treasury
              corp = share.corporation
              old_pres = corp.owner
              log_purchase("a share of #{company.name}", location, price)
              corp.make_manager(entity) if corp.owner.nil?
              share.buyable = true
              already_floated = corp.floated?
              # use transfer share to send payment to corporation
              bundle = ShareBundle.new(share)
              @game.share_pool.transfer_shares(bundle, entity, spender: entity, receiver: corp, price: price)
              if corp.floatable && corp.floated? && (already_floated == false)
                @game.float_corporation(corp)
                maybe_place_home_token(corp)
              end
              log_new_president(corp.owner, old_pres, corp)
              # debug_corp_log(share)
            when :president
              share = company.treasury
              corp = share.corporation
              old_pres = corp.owner
              share.buyable = true
              already_floated = corp.floated?
              log_purchase("the DIRECTOR's share of #{company.name}", location, price)
              corp.change_to_directed_corp(share, entity)
              @log << "#{corp.name} is now a DIRECTED company"
              if already_floated == false
                # corp wasn't a managed yet therefor director cert has priority and becomes president
                @game.float_corporation(corp)
                maybe_place_home_token(corp)
              elsif corp.manager_need_directors_share?
                # corp was a managed corp and manager needs director's cert
                corp.owner = corp.managers_share.owner
                @game.swap_director_share(share, entity, corp.owner, corp)
              end
              log_new_president(corp.owner, old_pres, corp)
              # debug_corp_log(share)
            when :private, :bond
              company.owner = entity
              entity.companies << company
              entity.spend(price, owner.nil? ? @game.bank : owner)
              log_purchase(company.name, location, price)
              @game.after_buy_company(entity, company, price) if entity.player?
            end
            # debugging_log('Process Buy Company')
          end

          def log_purchase(what, where, price)
            @log << "#{current_entity.name} buys #{what} from #{where} for #{@game.format_currency(price)}"
          end

          def log_new_president(new_pres, old_pres, corporation)
            pres_type = corporation.mangaged_company? ? 'Manager' : 'Director'
            @log << "#{new_pres.name} becomes the #{pres_type} of #{corporation.name}" unless new_pres == old_pres
          end

          # ------ Code for 'Buy Shares' Action ------

          def process_buy_shares(action)
            # Assign Manager if none yet
            corp = action.bundle.corporation
            corp.make_manager(action.entity) if corp.owner.nil?

            super
            @round.bought_from_market = true
          end

          # Modified: only buy shares from Market. Company Proxies used from IPO or Player Hand
          def can_buy_any?(entity)
            can_buy_any_from_market?(entity)
          end

          # Modified to reflect that selling doesn't restrict buying same corp later
          # Modified to disalow buying IPO or Corp owned shares
          def can_buy_shares?(entity, shares)
            return false if shares.empty?
            return false if shares.first.owner.corporation?
            return false if bought?

            min_share = nil
            shares.each do |share|
              next unless share.buyable

              min_share = share if !min_share || share.percent < min_share.percent
            end

            bundle = min_share&.to_bundle
            return unless bundle

            available_cash(entity) >= modify_purchase_price(bundle) && can_gain?(entity, bundle)
          end

          # Returns if a share can be bought via a normal buy actions
          # Modified to remove prior sold restriction.
          def can_buy?(entity, bundle)
            return unless bundle&.buyable
            return false if entity == bundle.owner
            return false if bundle.owner.corporation? && !buying_proxy? # buy IPO shares via company proxy

            available_cash(entity) >= modify_purchase_price(bundle) &&
              can_gain?(entity, bundle)
          end

          # ------ Code for Sell Actions ------

          # cert limit is the only time one must sell
          def must_sell?(entity)
            @game.num_certs(entity) > @game.cert_limit(entity)
          end

          # modified to remove sell limit checks, can't sell president's share
          def can_sell?(entity, bundle)
            return unless bundle
            return false unless selling_round?
            return false if entity != bundle.owner
            return false if bundle.presidents_share

            can_dump?(entity, bundle)
          end

          # modify for debugging
          def process_sell_shares(action)
            debug_corp_log(action.bundle, 'Beginning of Process Sell Shares')
            super
            debug_corp_log(action.bundle, 'End of Process Sell Shares')
          end

          def process_sell_company(action)
            company = action.company
            player = action.entity
            raise GameError, "Cannot sell #{company.id}" unless can_sell_company?(company)

            sell_company(player, company, action.price, @game.bank)
            track_action(action, company)
          end

          def sell_price(entity)
            return 0 unless can_sell_company?(entity)

            entity.value - @game.class::COMPANY_SALE_FEE
          end

          def can_sell_any_companies?(entity)
            sellable_companies(entity).any?
          end

          def sellable_companies(entity)
            return [] unless selling_round?
            return [] unless entity.player?

            entity.companies
          end

          def can_sell_company?(entity)
            return false unless selling_round?
            return false unless entity.company?
            return false if entity.owner == @game.bank

            true
          end

          def sell_company(player, company, price, bank)
            company.owner = bank
            bank.companies.push(company)
            player.companies.delete(company)
            bank.spend(price, player) if price.positive?
            @log << "#{player.name} sells #{company.name} to the Bank for #{@game.format_currency(price)}"
            @round.players_sold[player][company] = :now
          end
        end
      end
    end
  end
end
