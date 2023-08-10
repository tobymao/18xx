# frozen_string_literal: true

require_relative 'base_buy_sell_par_shares'

module Engine
  module Game
    module G1841
      module Step
        class BuySellParShares < BaseBuySellParShares
          def flexible_buy?(entity)
            entity&.player? && @game.allow_player2player_sales?
          end

          def can_buy_any_from_player?(entity)
            return false unless flexible_buy?(entity)
            return false unless entity.cash.positive?
            return false if bought?

            @game.players.reject { |p| p == entity }.any? { |p| flexible_can_buy_any_shares?(entity, p.shares) }
          end

          def flexible_can_buy_any_shares?(entity, shares)
            return false if shares.empty?

            shares.each do |share|
              next if entity == share.owner || @round.players_sold[entity][share.corporation]
              next if share.president && !@game.pres_change_ok?(share.corporation)
              next unless can_gain?(entity, share.to_bundle)

              return true
            end
            false
          end

          def flexible_bundles(buyer, owner, corporation)
            shares = owner.shares_of(corporation).sort_by(&:percent)
            shares.reject! { |s| s.president && !@game.pres_change_ok?(corporation) }
            bundles = @game.all_bundles_for_corporation(owner, corporation, shares: shares)
            bundles.select { |bundle| can_sell_to_player?(buyer, owner, bundle) }
          end

          def can_sell_to_player?(buyer, owner, bundle)
            return unless bundle
            return false if owner != bundle.owner
            return true unless (pres = bundle.presidents_share)
            return true if bundle.percent >= pres.percent # new owner can take presidency

            # we are dealing with a partial pres share, somebody better have
            # enough take the presidency
            sh = bundle.corporation.player_share_holders(corporate: true)
            return true if sh[buyer]&.positive? # buyer just needs 1 share

            (sh.reject { |k, _| k == owner }.values.max || 0) >= pres.percent
          end

          def flexible_can_buy_shares?(entity, shares, price)
            return false if shares.empty? || entity.cash < price || bought?
            return false if @round.players_sold[entity][shares[0].corporation]

            pres = shares.find(&:president)
            return false if pres && !@game.pres_change_ok?(pres.corporation)

            can_gain?(entity, ShareBundle.new(shares))
          end

          def process_buy_shares(action)
            return super unless action.bundle.owner.player?

            # player to player purchase
            #
            old_circular = @game.circular_corporations
            entity = action.entity
            price = action.total_price
            bundle = action.bundle
            owner = bundle.owner
            corporation = bundle.corporation
            raise GameError, 'Not enough cash for purchase' unless entity.cash >= price
            raise GameError, 'Cannot purchase these shares' unless flexible_can_buy_shares?(entity, bundle.shares, price)

            # can't use share_pool.buy_shares since it uses bundle.share_price
            @log << "-- #{entity.name} buys a #{bundle.percent}% share"\
                    " of #{corporation.name} from #{owner.name} for #{@game.format_currency(price)} --"

            @game.share_pool.transfer_shares(bundle,
                                             entity,
                                             spender: entity,
                                             receiver: owner,
                                             price: price,
                                             allow_president_change: @game.pres_change_ok?(corporation))

            track_action(action, corporation)
            @game.update_frozen!
            return if @game.circular_corporations.none? { |c| !old_circular.include?(c) }

            raise GameError, 'Cannot purchase if it causes a circular chain of ownership'
          end

          def company_president_share(company)
            corp = @game.corporation_by_id(company&.sym)
            return nil unless corp

            owner = company.owner
            owner = @game.share_pool if owner == @game.bank
            owner.shares_of(corp).find(&:president)
          end

          def purchasable_companies(entity)
            return [] if bought? || !entity.cash.positive? || !@game.allow_player2player_sales?

            @game.companies.select { |c| !c.closed? && c.owner.player? && can_buy_company?(entity, c) }
          end

          def buyable_bank_owned_companies(entity)
            return [] if bought? || @game.turn < 2

            @game.companies.select { |c| !c.closed? && c.owner == @game.bank && can_buy_company?(entity, c) }
          end

          # this works for both buying from the bank as well as players
          def can_buy_company?(player, company)
            return false unless player.player?
            return false if company.closed?
            return false unless (owner = company.owner)
            return false if owner.player? && !@game.allow_player2player_sales?
            return false if !owner.player? && @game.turn < 2

            # can afford?
            pres = company_president_share(company)
            pres_value = pres ? pres.corporation.share_price.price * 2 : 0
            price = owner.player? ? 1 : company.value + pres_value
            return false unless player.cash >= price

            # can take pres share?
            return true unless pres

            can_gain?(player, pres.to_bundle)
          end

          def process_buy_company(action)
            entity = action.entity
            company = action.company
            price = action.price
            owner = company.owner

            # increase price when bought from bank to account for president's share
            pres = company_president_share(company)
            extra = pres && !owner.player? ? pres.corporation.share_price.price * 2 : 0

            raise GameError, "Not enough cash to buy #{action.company.name}" unless entity.cash >= (price + extra)
            raise GameError, "Cannot buy #{action.company.name}" unless can_buy_company?(entity, company)

            super

            return unless pres

            if extra.positive?
              @log << "#{entity.name} pays the bank for the president's share of #{pres.corporation.name}"
              entity.spend(extra, @game.bank)
            end
            @log << "#{entity.name} takes the president's share and becomes president of #{pres.corporation.name}"
            @game.share_pool.transfer_shares(pres.to_bundle, entity, allow_president_change: false)
            pres.corporation.owner = entity
          end
        end
      end
    end
  end
end
