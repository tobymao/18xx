# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_companies'
require_relative 'minor_exchange'

module Engine
  module Game
    module G18Ardennes
      module Step
        class BuySellParSharesCompanies < Engine::Step::BuySellParSharesCompanies
          include MinorExchange

          def actions(entity)
            return [] unless entity == current_entity
            return [] if bought?
            return [] if entity.bankrupt
            return %w[bankrupt] if @game.bankrupt?(entity)
            return limit_actions(entity) if must_sell?(entity)
            return par_actions(entity) if @game.under_obligation?(entity)

            super
          end

          def auto_actions(entity)
            programmed_actions = super
            return programmed_actions if programmed_actions

            # The only situation that needs an auto action is when the only
            # possible (non-pass) action is buy_shares, and this is for an
            # exchange only (no shares can be bought), and there is no legal
            # exchange possible as the minor companies owned by the player
            # are not connected to any public companies.  The connection
            # between the minor and public companies is not checked in
            # `actions` to avoid calls to the graph when the game is loading.
            return unless actions(entity) == %w[buy_shares pass]
            return if @game.under_obligation?(entity)
            return if can_buy_any_from_market?(entity)
            return if can_buy_any_from_ipo?(entity)
            return if can_exchange_any?(entity, check_connection: true)

            [Engine::Action::Pass.new(entity)]
          end

          def bankruptcy_description(player)
            if !under_limit?(player) &&
               !can_sell_any?(player) &&
               !can_sell_any_companies?(player)

              "#{player.name} is at certificate and does not have anything " \
                'that can be sold to free up the certificate slot needed to ' \
                'start a public company.'
            else
              concession = player.companies
                                 .select { |c| c.type == :concession }
                                 .min { |c| @game.min_concession_cost(c) }

              "#{player.name} needs at least " \
                "#{@game.format_currency(@game.min_concession_cost(concession))} " \
                "to start #{concession.name} but can only raise " \
                "#{@game.format_currency(@game.liquidity(player))}."
            end
          end

          def sellable_companies(entity)
            return [] unless entity.player?

            # Only the GL is sellable. Make sure concessions aren't visible.
            entity.companies.select { |company| company.type == :minor }
          end

          # Returns an array of shares that can be gained in exchange for a
          # minor company. This is used to stop any pool shares being offered
          # for exchange unless the president of the public company has
          # previously denied a request to exchange for a treasury share, or
          # if there are no treasury shares available. It does not check for
          # connection between the public and minor companies, that will have
          # already been tested in Entities#exchange_corporations.
          # @param corporation [Corporation] The public company to check for
          #        exchangeable pool shares.
          # @param ability [Ability::Exchange] The exchange ability associated
          #        with a minor company.
          # @return [Array<Share>] The pool shares that could be gained in
          #         exchange for the minor company.
          def exchangeable_pool_shares(corporation, ability)
            minor = ability.owner
            shares = @game.share_pool.shares_by_corporation[corporation].take(1)
            return [] if shares.empty?
            return shares if corporation.owner == minor.owner
            return shares if corporation.receivership?

            @round.refusals[corporation].include?(minor) ? shares : []
          end

          def can_buy?(entity, bundle)
            return super unless bundle
            # If a minor is in receivership and its share price is in the grey
            # zone then its presidency cannot be bought.
            return false if bundle.corporation.share_price.price.zero?

            super
          end

          # Exchanging a minor for a share in a floated major corporation is
          # done as a buy_share action.
          def can_buy_any?(entity)
            return false if bought?

            super || can_exchange_any?(entity, check_connection: false)
          end

          def can_gain?(entity, bundle, exchange: false)
            # Cannot exchange a minor for a treasury share of a public company
            # that is in receivership.
            return false if exchange && bundle.corporation.receivership? &&
                            bundle.owner != @game.share_pool
            # Can go above 60% ownership if exchanging a minor for a share or
            # if buying a share from the open market.
            return true if exchange
            return true if (bundle.owner == @game.share_pool) &&
                           (@game.num_certs(entity) < @game.cert_limit)

            super
          end

          # Can this ShareBundle be sold to the open market?
          def can_dump?(entity, bundle)
            # The implementation of this method in Step::BuySellParSharesCompanies
            # is for games where the president's certificate can be sold to the
            # market. This isn't true in 18Ardennes, the method implemented in
            # Step::BuySellParShares is correct.
            bundle.can_dump?(entity)
          end

          # Checks whether a player can afford to exchange one of their minors
          # for a share in a major corporation.
          # If `check_connection` is false this method does not check whether
          # there is a track connection between the minor and the major, which
          # is required to carry out the exchange. This is not checked to avoid
          # having to recalculate the game graph whilst a game is being loaded.
          def can_exchange_any?(player, check_connection: false)
            majors = @game.major_corporations.select do |corp|
              corp.ipoed && (corp.num_treasury_shares.positive? || corp.num_market_shares.positive?)
            end
            return false if majors.empty?

            @game.minor_corporations.any? do |minor|
              next false unless minor.owner == player
              next false if minor.share_price.price.zero?

              max_price = (minor.share_price.price * 2) + @game.liquidity(player)
              majors.any? do |corp|
                (corp.share_price.price <= max_price) &&
                  (!check_connection || @game.major_minor_connected?(corp, minor))
              end
            end
          end

          # Corporations whose cards are visible in the stock round.
          # Hide public companies whose concessions have not yet been auctioned.
          def visible_corporations
            majors = @game.sorted_corporations.select do |corporation|
              corporation.floated || !corporation.par_via_exchange.owner.nil?
            end
            majors.sort + @game.minor_corporations.sort
          end

          # Valid par prices for public companies.
          def get_par_prices(_player, _corporation)
            @game.stock_market.par_prices.select { |pp| pp.types.include?(:par_2) }
          end

          # This function is called from View::Game::Par to calculate how many
          # shares can be bought at each possible par price. In 18Ardennes you
          # get an extra share when floating a public company, part paid for by
          # exchanging the pledged minor, so pretend that the player has extra
          # cash to pay for this extra share.
          def available_par_cash(player, corporation, share_price: nil)
            minor = @game.pledged_minors[corporation]
            available_cash(player) + @game.minor_sale_value(minor, share_price)
          end

          def process_par(action)
            check_too_much_sold(action)

            super

            major = action.corporation
            minor = @game.pledged_minors[major]
            concession = major.par_via_exchange

            concession.close!
            exchange_minor(minor, major.treasury_shares.first.to_bundle, :all)
          end

          def process_bankrupt(action)
            @game.bankrupt!(action.entity, @game.bank)
          end

          def log_skip(entity)
            # Don't print a '[player] has no valid actions and passes' message
            # after exchanging a minor for a share.
            super if @round.current_actions.empty?
          end

          private

          # Actions when a player is under obligation to start a public company.
          def par_actions(entity)
            actions = []
            actions << 'par' if under_limit?(entity)
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'sell_company' if can_sell_any_companies?(entity)
            # The player is at certificate limit and they do not have any
            # sellable shares.
            actions << 'bankrupt' if actions.empty?

            actions
          end

          # Actions when a player is over the certificate limit.
          def limit_actions(entity)
            if can_sell_any_companies?(entity)
              %w[sell_shares sell_company]
            else
              %w[sell_shares]
            end
          end

          def under_limit?(player)
            @game.num_certs(player) < @game.cert_limit(player)
          end

          # Returns the price of the cheapest item (share or company) in a
          # sell action. If multiple shares were sold then the price returned
          # is for an individual share, not the bundle.
          def cheapest_sale(action)
            case action
            when Engine::Action::SellShares
              action.bundle.shares.map(&:price).min
            when Engine::Action::SellCompany
              action.company.value
            end
          end

          # A player is only allowed to sell shares (or the GL minor) before
          # starting a public company if they use the cash from the sale to
          # start the public company at a higher price than would have been
          # possible without the sale. This method throws an error if the par
          # price could have been used with fewer items sold.
          def check_too_much_sold(par_action)
            return if @round.current_actions.empty?

            player = par_action.entity
            major = par_action.corporation
            minor = @game.pledged_minors[major]

            par_price = par_action.share_price
            par_cost = (3 * par_price.price) -
                       @game.minor_sale_value(minor, par_price)
            surplus_cash = available_cash(player) - par_cost

            return if @round.current_actions.all? do |sale_action|
              cheapest_sale(sale_action) > surplus_cash
            end

            msg = 'More shares have been sold than were needed to start ' \
                  "#{major.id} at a par price of " \
                  "#{@game.format_currency(par_price.price)}. Either choose " \
                  'a higher par price or undo some or all of the sales.'
            raise GameError, msg
          end
        end
      end
    end
  end
end
