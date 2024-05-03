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
            return super if bought?
            return super unless @game.under_obligation?(entity)
            return %w[bankrupt] if @game.bankrupt?(entity)

            actions = []
            actions << 'par' if under_limit?(entity)
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'sell_company' if can_sell_any_companies?(entity)
            # TODO: handle this properly.
            # Maybe stop the player from bidding for a major if they are at
            # certificate limit and do not have any sellable shares.
            raise GameError, 'Cannot sell shares or start major company' if actions.empty?

            actions
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
            concession = player.companies
                               .select { |c| c.type == :concession }
                               .min { |c| @game.min_concession_cost(c) }

            "#{player.name} needs at least " \
              "#{@game.format_currency(@game.min_concession_cost(concession))} " \
              "to start #{concession.name} but can only raise " \
              "#{@game.format_currency(@game.liquidity(player))}."
          end

          def sellable_companies(entity)
            return [] unless entity.player?

            # Only the GL is sellable. Make sure concessions aren't visible.
            entity.companies.select { |company| company.type == :minor }
          end

          # Exchanging a minor for a share in a floated major corporation is
          # done as a buy_share action.
          def can_buy_any?(entity)
            return false if bought?

            super || can_exchange_any?(entity, check_connection: false)
          end

          def can_gain?(entity, bundle, exchange: false)
            # Can go above 60% ownership if exchanging a minor for a share.
            exchange || super
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
          # Hide those whose concessions have not yet been auctioned.
          def visible_corporations
            @game.major_corporations.select do |corporation|
              corporation.floated || !corporation.par_via_exchange.owner.nil?
            end
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
            super

            major = action.corporation
            minor = @game.pledged_minors[major]
            concession = major.par_via_exchange

            concession.close!
            exchange_minor(minor, major.treasury_shares.first.to_bundle, false)
          end

          def process_bankrupt(action)
            player = action.entity

            # All shares and the GL go to the bank pool.
            # Concessions can be purchased by another player in a future auction.
            sell_bankrupt_shares(player)
            player.companies.each do |company|
              company.owner = company.type == :minor ? @game.bank : nil
            end
            player.companies.clear

            player.spend(player.cash, @game.bank) if player.cash.positive?
            @game.declare_bankrupt(player)
          end

          private

          def sell_bankrupt_shares(player)
            @log << "-- #{player.name} goes bankrupt and sells remaining shares --"

            player.shares_by_corporation.each do |corporation, shares|
              next if shares.empty?

              bundles = @game.bundles_for_corporation(player, corporation)
              @game.share_pool.sell_shares(bundles.last)
            end
          end

          def under_limit?(player)
            @game.num_certs(player) < @game.cert_limit(player)
          end
        end
      end
    end
  end
end
