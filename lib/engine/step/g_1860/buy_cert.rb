# frozen_string_literal: true

require_relative '../base'
require_relative '../../action/par'

module Engine
  module Step
    module G1860
      class BuyCert < Base
        attr_reader :companies

        ALL_ACTIONS = %w[bid pass par].freeze
        AUCTION_ACTIONS = %w[bid pass].freeze
        PASS_ACTION = %w[pass].freeze
        MIN_BID_RAISE = 5

        def setup
          @companies = @game.companies.select { |c| c.all_abilities.any? }.sort +
                       @game.corporations.select { |c| c.layer == 1 }
          @bids = {}
          setup_auction
        end

        def available
          @companies.select { |c| can_afford?(current_entity, c) }
        end

        def may_purchase?(_company)
          true
        end

        def auctioning
          :turn if in_auction?
        end

        def bids
          {}
        end

        def visible?
          true
        end

        def players_visible?
          true
        end

        def name
          'Buy/Par'
        end

        def description
          in_auction? ? 'Bid on turn to buy' : 'You must buy a company or start a corporation'
        end

        def finished?
          @companies.empty?
        end

        def actions(entity)
          return [] if finished?
          return [] unless entity == current_entity
          return ALL_ACTIONS unless in_auction?
          return AUCTION_ACTIONS if min_player_bid + cheapest_price <= entity.cash

          PASS_ACTION
        end

        def process_par(action)
          share_price = action.share_price
          corporation = action.corporation
          entity = action.entity
          @game.game_error("#{corporation} cannot be parred") unless corporation.can_par?(entity)

          @game.stock_market.set_par(corporation, share_price)
          shares = corporation.shares.first
          if entity.cash >= 2 * share_price.price
            @game.share_pool.buy_shares(entity, shares)
          else
            buy_discounted_shares(entity, shares, entity.cash)
          end
          @companies.delete(corporation)
          @round.next_entity_index!
          setup_auction
        end

        def process_pass(action)
          player = action.entity

          @log << "#{player.name} passes bidding"

          @bids.delete(player)

          resolve_auction
        end

        def process_bid(action)
          player = action.entity
          price = action.price

          if !in_auction?
            buy_company(player, action.company, price)
          else
            if price > max_player_bid(player)
              @game.game_error("Cannot afford bid. Maximum possible bid is #{max_player_bid(player)}")
            end

            @log << "#{player.name} bids #{@game.format_currency(price)}"

            @bids[player] = price
            resolve_auction
          end
        end

        def get_par_prices(entity, corp)
          prices = @game.par_prices(corp).select { |p| p.price * 2 <= entity.cash }
          if prices.empty? && cheapest_thing.corporation?
            # assumes all corps available have same minimum par price
            return [@game.par_prices(corp).min_by(&:price)]
          end

          prices
        end

        def active_entities
          return [@bids.min_by { |_k, v| v }.first] if in_auction?

          super
        end

        def min_increment
          1
        end

        def min_player_bid
          highest_player_bid + MIN_BID_RAISE
        end

        def max_player_bid(entity)
          entity.cash - cheapest_price
        end

        def min_bid(company)
          return unless company

          company.value
        end

        def companies_pending_par
          false
        end

        def visible
          true
        end

        def committed_cash(player, _show_hidden = false)
          if @bids[player] && !@bids[player].negative?
            @bids[player] + cheapest_price
          else
            0
          end
        end

        private

        def in_auction?
          @bids.any?
        end

        def highest_player_bid
          any_bids? ? @bids.max_by { |_k, v| v }.last : 0
        end

        def highest_bid
          in_auction? ? @bids.max_by { |_k, v| v }.last : 0
        end

        def any_bids?
          in_auction? && @bids.max_by { |_k, v| v }.last.positive?
        end

        def cheapest_thing
          @companies.min_by { |c| c.company? ? c.value : @game.par_prices(c).map(&:price).min * 2 }
        end

        def cheapest_price
          thing = cheapest_thing
          thing.company? ? thing.value : @game.par_prices(thing).map(&:price).min * 2
        end

        def setup_auction
          @bids.clear
          @first_player = current_entity
          start_idx = entity_index
          size = entities.size
          # initialize bids to preserve player order starting with current player
          entities.each_index do |idx|
            @bids[entities[idx]] = -size + (idx - start_idx) % size
          end
        end

        def resolve_auction
          return if @bids.size > 1
          return if @bids.one? && highest_bid.negative?

          if @bids.any?
            winning_bid = @bids.to_a.flatten
            player = winning_bid.first
            price = winning_bid.last
            player.spend(price, @game.bank) if price.positive?
          else
            player = @first_player
            price = 0
          end
          @log << "#{player.name} wins auction for #{@game.format_currency(price)}"
          @bids.clear
          @round.goto_entity!(player)
        end

        def can_afford?(entity, company)
          # guaranteed to be able to afford the cheapest company or corporation
          return true if !in_auction? && company == cheapest_thing
          return true if !in_auction? && company.corporation? && cheapest_thing.corporation?

          cost = company.company? ? company.value : @game.par_prices(company).map(&:price).min * 2
          entity.cash >= cost
        end

        def buy_discounted_shares(entity, shares, discounted_price)
          bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
          corporation = bundle.corporation
          par_price = corporation.par_price&.price
          ipoed = corporation.ipoed

          corporation.ipoed = true if bundle.presidents_share

          if ipoed != corporation.ipoed
            @log << "#{entity.name} pars #{corporation.name} at "\
                    "#{@game.format_currency(par_price)}"
          end

          share_str = "a #{bundle.percent}% share of #{corporation.name}"

          @log << "#{entity.name} buys #{share_str} "\
            "from the #{@game.class::IPO_NAME} "\
            "for #{@game.format_currency(discounted_price)}"

          @game.share_pool.transfer_shares(
            bundle,
            entity,
            spender: entity,
            receiver: @game.bank,
            price: discounted_price
          )
        end

        def buy_company(player, company, listed_price)
          price = [listed_price, player.cash].min
          company.owner = player
          player.companies << company
          player.spend(price, @game.bank) if price.positive?
          @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
          @companies.delete(company)
          @round.next_entity_index!
          setup_auction
        end
      end
    end
  end
end
