# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../action/par'

module Engine
  module Game
    module GFrost1831
      module Step
        class BuyCert < Engine::Step::Base
          attr_reader :companies

          AUCTION_ACTIONS = %w[bid pass].freeze
          BUY_ACTION = %w[bid par].freeze
          PASS_ACTION = %w[pass].freeze
          PAR_ACTION = %w[par].freeze
          MIN_BID_RAISE = 5

          def setup
            @companies = @game.companies.dup
            @bids = {}
            @pending_par = nil
            @all_passed = false
            setup_auction
          end

          def available
            return [pending_par_corporation] if @pending_par
            return @companies.select { |c| can_afford?(current_entity, c) } unless @all_passed

            affordable = @companies.select { |c| current_entity.cash >= cost(c) }
            affordable.empty? ? [@companies.min_by { |c| cost(c) }] : affordable
          end

          def may_purchase?(_company)
            true
          end

          def auctioning
            return pending_par_corporation if @pending_par

            :turn if in_auction?
          end

          def bids
            {}
          end

          def visible?
            true
          end

          def visible
            true
          end

          def players_visible?
            true
          end

          def name
            'Buy'
          end

          def description
            in_auction? ? 'Bid on turn to buy' : 'Choose a company to buy'
          end

          def finished?
            @companies.empty? && !@pending_par
          end

          def actions(entity)
            return PAR_ACTION if @pending_par && entity == current_entity
            return [] if finished?
            return [] unless entity == current_entity
            return BUY_ACTION unless in_auction?
            return AUCTION_ACTIONS if min_player_bid + cheapest_price <= entity.cash

            PASS_ACTION
          end

          def active_entities
            return [@pending_par.owner] if @pending_par
            return [@bids.min_by { |_k, v| v }.first] if in_auction?

            super
          end

          def process_par(action)
            corporation = action.corporation
            raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, action.entity)

            par_and_pay(action.entity, corporation, action.share_price)
            @pending_par = nil
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

            return buy_company(player, action.company, price) unless in_auction?

            raise GameError, "Bid must be a multiple of #{@game.format_currency(MIN_BID_RAISE)}" if (price % MIN_BID_RAISE) != 0
            if price > max_player_bid(player)
              raise GameError, "Cannot afford bid. Maximum possible bid is #{max_player_bid(player)}"
            end
            raise GameError, "Must bid at least #{min_player_bid}" if price < min_player_bid

            @log << "#{player.name} bids #{@game.format_currency(price)}"

            @bids[player] = price
            resolve_auction
          end

          def get_par_prices(entity, _corp)
            prices = @game.stock_market.par_prices
            affordable = prices.select { |p| p.price * 2 <= entity.cash }
            affordable.empty? ? [prices.min_by(&:price)] : affordable
          end

          def min_increment
            MIN_BID_RAISE
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

          def setup_auction
            @bids.clear
            @first_player = current_entity
            start_idx = entity_index
            size = entities.size
            # initialize bids to preserve player order starting with current player
            entities.each_index do |idx|
              @bids[entities[idx]] = -size + ((idx - start_idx) % size)
            end
          end

          def resolve_auction
            @all_passed = @bids.empty?
            return if @bids.size > 1
            return if @bids.one? && highest_bid.negative?

            if @bids.any?
              player, price = @bids.first
              player.spend(price, @game.bank) if price.positive?
            else
              player = @first_player
              price = 0
            end
            @log << "#{player.name} wins auction for #{@game.format_currency(price)}"
            @bids.clear
            @round.goto_entity!(player)
          end

          def president_share(company)
            company.all_abilities.find { |a| a.type == :shares }&.shares&.find(&:president)
          end

          def pending_par_corporation
            president_share(@pending_par).corporation
          end

          def min_par_cost
            @game.stock_market.par_prices.map(&:price).min * 2
          end

          def cost(company)
            president_share(company) ? min_par_cost : company.value
          end

          def cheapest_price
            @companies.map { |c| cost(c) }.min || 0
          end

          def can_afford?(entity, company)
            return entity.cash >= min_par_cost if president_share(company)
            return true if !in_auction? && company.value == cheapest_face_value

            entity.cash >= company.value
          end

          def cheapest_face_value
            @companies.reject { |c| president_share(c) }.map(&:value).min
          end

          def buy_company(player, company, _listed_price)
            price = [company.value, player.cash].min
            @log << "#{player.name} cannot afford full price, pays #{@game.format_currency(price)}" if price < company.value

            company.owner = player
            player.companies << company
            player.spend(price, @game.bank) if price.positive?
            @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
            @game.after_buy_company(player, company, price)
            @companies.delete(company)

            all_passed = @all_passed
            @all_passed = false
            share = president_share(company)

            if !share
              finish_turn
            elsif all_passed && player.cash < min_par_cost
              par_and_pay(player, share.corporation, @game.stock_market.par_prices.min_by(&:price))
              finish_turn
            else
              @pending_par = company
            end
          end

          def finish_turn
            @round.next_entity_index!
            setup_auction
          end

          def par_and_pay(player, corporation, share_price)
            @game.par_corporation(corporation, share_price)
            corporation.ipoed = true
            price = [share_price.price * 2, player.cash].min
            @game.share_pool.transfer_shares(
              corporation.shares.first.to_bundle,
              player,
              spender: player,
              receiver: @game.bank,
              price: price
            )
            @log << "#{player.name} pars #{corporation.name} at #{@game.format_currency(share_price.price)} "\
                    "(pays #{@game.format_currency(price)})"
          end
        end
      end
    end
  end
end
