# frozen_string_literal: true

require_relative '../base'
require_relative '../../action/buy_company'
require_relative '../../action/buy_shares'
require_relative '../../action/par'

module Engine
  module Step
    module G1860
      class BuyCert < Base
        attr_reader :companies, :in_auction

        AUCTION_ACTIONS = %w[simple_bid pass].freeze
        PASS_ACTION = %w[pass].freeze
        MIN_BID_RAISE = 5

        def setup
          @companies = @game.companies.select { |c| c.all_abilities.any? }.sort +
                       @game.corporations.select { |c| c.layer == 1 }
          @bids = {}
          setup_auction
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
          @in_auction = true
        end

        def available
          @companies
        end

        def may_purchase?(_company)
          true
        end

        def auctioning; end

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
          @in_auction ? 'Bid on turn to buy' : 'You must buy a company or start a corporation'
        end

        def finished?
          @companies.empty?
        end

        def actions(entity)
          return [] if finished?
          return [] unless entity == current_entity
          return AUCTION_ACTIONS if @in_auction && min_player_bid + cheapest_price <= entity.cash
          return PASS_ACTION if @in_auction

          actions = []
          actions << 'par' if can_ipo_any?(entity)
          actions << 'buy_company' if purchasable_companies(entity).any?
          if actions.empty?
            actions << (cheapest_thing.company? ? 'buy_company' : 'par')
          end

          actions
        end

        def min_player_bid
          highest_player_bid + MIN_BID_RAISE
        end

        def max_player_bid(entity)
          entity.cash - cheapest_price
        end

        def highest_player_bid
          @in_auction && any_bids? ? @bids.max_by { |_k, v| v }.last : 0
        end

        def highest_bid
          @in_auction ? @bids.max_by { |_k, v| v }.last : 0
        end

        def any_bids?
          @in_auction && @bids.max_by { |_k, v| v }.last.positive?
        end

        def cheapest_thing
          @companies.min_by { |c| c.company? ? c.value : @game.par_prices(c).map(&:price).min }
        end

        def cheapest_price
          thing = cheapest_thing
          thing.company? ? thing.value : @game.par_prices(thing).map(&:price).min
        end

        def can_ipo_any?(entity)
          @companies.any? { |c| c.corporation? && c.can_par?(entity) && can_buy?(entity, c.shares.first&.to_bundle) }
        end

        def can_buy?(entity, bundle)
          return unless bundle
          return unless bundle.buyable

          entity.cash >= bundle.price
        end

        def purchasable_companies(entity)
          @companies.select { |c| c.company? && c.value <= entity.cash }
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

        def process_buy_company(action)
          player = action.entity
          price = [action.price, player.cash].min
          company = action.company
          buy_company(player, company, price)
          @companies.delete(company)
          @round.next_entity_index!
          setup_auction
        end

        def buy_company(player, company, price)
          company.owner = player
          player.companies << company
          player.spend(price, @game.bank) if price.positive?
          @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
        end

        def process_pass(action)
          player = action.entity

          @log << "#{player.name} passes bidding"

          @bids.delete(player)

          resolve_auction
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
          @in_auction = false
          @bids.clear
          @round.goto_entity!(player)
        end

        def process_simple_bid(action)
          player = action.entity
          price = action.price

          if price > max_player_bid(player)
            @game.game_error("Cannot afford bid. Maximum possible bid is #{max_player_bid(player)}")
          end

          @log << "#{player.name} bids #{@game.format_currency(price)}"

          @bids[player] = price
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
          return [@bids.min_by { |_k, v| v }.first] if @in_auction

          super
        end

        def min_increment
          1
        end

        def can_afford?(entity, company)
          # guaranteed to be able to afford the cheapest company or corporation
          return true if company == cheapest_thing
          return true if company.corporation? && cheapest_thing.corporation?

          cost = company.company? ? company.value : @game.par_prices(company).map(&:price).min
          entity.cash >= cost
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
      end
    end
  end
end
