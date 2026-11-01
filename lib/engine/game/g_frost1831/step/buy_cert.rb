# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../action/par'

module Engine
  module Game
    module GFrost1831
      module Step
        class BuyCert < Engine::Step::Base
          # Open auction in 6 cycles. Each cycle:
          # 1. Players bid in turn order (minimum raise £5)
          # 2. Passing removes you from the cycle
          # 3. Last player remaining wins
          # 4. Winner chooses any available company and pays bid + face value
          # 5. If all pass: first to pass chooses and pays only face value
          # 6. Next cycle starts left of winner

          attr_reader :companies

          AUCTION_ACTIONS = %w[bid pass].freeze
          BUY_ACTION = %w[bid par].freeze
          PASS_ACTION = %w[pass].freeze
          MIN_BID_RAISE = 5

          def setup
            @companies = @game.companies.dup
            @bids = {}
            @last_winner = nil
            @pending_par = nil
            @all_passed = false
            @first_to_pass = nil
            setup_auction
          end

          def available
            # When pending par, show GJ corporation for par selection
            if @pending_par
              gj = @game.corporations.find { |c| c.id == 'GJ' }
              return [gj].compact
            end

            # After all-pass: winner pays only face value (or 2x par for P6)
            # Show all companies they can afford at face value.
            # If they can't afford ANY, force the cheapest (rule 6.3: pay what you can)
            if @all_passed
              affordable = @companies.select { |c| can_afford_face_value?(current_entity, c) }
              if affordable.empty?
                cheapest = @companies.min_by { |c| c.sym == 'PGJ' ? 120 : c.value }
                return [cheapest].compact
              end
              return affordable
            end

            @companies.select { |c| can_afford?(current_entity, c) }
          end

          def may_purchase?(_company)
            true
          end

          def auctioning
            return @game.corporations.find { |c| c.id == 'GJ' } if @pending_par

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
            'Buy'
          end

          def description
            in_auction? ? 'Bid on turn to buy' : 'Choose a company to buy'
          end

          def finished?
            @companies.empty? && !@pending_par
          end

          def actions(entity)
            return [] if finished?
            return [] unless entity == current_entity

            # After buying P6, must set par for GJ
            return %w[par] if @pending_par

            return BUY_ACTION unless in_auction?
            return AUCTION_ACTIONS if min_player_bid + cheapest_price <= entity.cash

            PASS_ACTION
          end

          def process_par(action)
            # P6 (Grand Junction): winner chooses par value and pays 2x par
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            raise GameError, "#{corporation} cannot be parred" unless @game.can_par?(corporation, entity)

            @game.stock_market.set_par(corporation, share_price)
            corporation.ipoed = true

            shares = corporation.shares.first

            # Pay 2x par value for the presidency share
            cost = share_price.price * 2
            # If player can't afford full 2x par, pay what they can (manual edge case)
            actual_cost = [cost, entity.cash].min

            @game.share_pool.transfer_shares(
              shares.to_bundle,
              entity,
              spender: entity,
              receiver: @game.bank,
              price: actual_cost
            )

            @log << "#{entity.name} pars #{corporation.name} at #{@game.format_currency(share_price.price)} "\
                    "(pays #{@game.format_currency(actual_cost)})"

            @pending_par = nil
            @round.next_entity_index!
            setup_auction
          end

          def process_pass(action)
            player = action.entity

            @log << "#{player.name} passes bidding"

            # Track first player to pass (for rule 6.3)
            @first_to_pass ||= player

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
                raise GameError, "Cannot afford bid. Maximum possible bid is #{@game.format_currency(max_player_bid(player))}"
              end

              raise GameError, "Must bid at least #{@game.format_currency(min_player_bid)}" if price < min_player_bid
              raise GameError, 'Bid must be a multiple of £5' if (price % 5) != 0

              @log << "#{player.name} bids #{@game.format_currency(price)}"

              @bids[player] = price
              resolve_auction
            end
          end

          def get_par_prices(entity, corp)
            # Player pays 2x par for P6/GJ presidency
            prices = @game.par_prices(corp).select { |p| p.price * 2 <= entity.cash }
            # If player can't afford any par, force minimum (£60) per manual
            if prices.empty?
              prices = [@game.par_prices(corp).min_by(&:price)]
            end
            prices
          end

          def active_entities
            return [@pending_par] if @pending_par
            return [@bids.min_by { |_k, v| v }.first] if in_auction?

            super
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

          def cheapest_price
            # PGJ has value 0 but actually costs 2x minimum par (£120)
            # For committed cash calculation, use the cheapest actual cost
            prices = @companies.map do |c|
              if c.sym == 'PGJ'
                min_par = @game.stock_market.par_prices.map(&:price).min
                min_par * 2
              else
                c.value
              end
            end
            prices.min || 0
          end

          def setup_auction
            @bids.clear
            @first_to_pass = nil
            @first_player = current_entity
            start_idx = entity_index
            size = entities.size
            # Initialize bids to preserve player order starting with current player
            entities.each_index do |idx|
              @bids[entities[idx]] = -size + ((idx - start_idx) % size)
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
              @all_passed = false
            else
              # All passed: first to pass wins and pays only face value (or what they can)
              player = @first_to_pass || @first_player
              price = 0
              @all_passed = true
            end
            @log << "#{player.name} wins auction for #{@game.format_currency(price)}"
            @bids.clear
            @round.goto_entity!(player)
          end

          def can_afford?(entity, company)
            if company.respond_to?(:sym) && company.sym == 'PGJ'
              return can_afford_p6?(entity)
            end

            # Corporations (GJ) check par affordability
            return can_afford_p6?(entity) if company.respond_to?(:ipoed) && !company.ipoed

            # Always allow buying the cheapest (manual: pay what you can)
            non_p6 = @companies.reject { |c| c.sym == 'PGJ' }
            cheapest_val = non_p6.map(&:value).min
            return true if !in_auction? && company.respond_to?(:value) && company.value == cheapest_val

            entity.cash >= company.value
          end

          def can_afford_p6?(entity)
            min_par = @game.stock_market.par_prices.map(&:price).min
            entity.cash >= min_par * 2
          end

          # Check if entity can afford a company at face value only (used in all-pass scenario)
          def can_afford_face_value?(entity, company)
            if company.sym == 'PGJ'
              return can_afford_p6?(entity)
            end

            entity.cash >= company.value
          end

          def force_par_gj(player)
            # Rule 6.3: par fixed at £60, player pays what they can (up to £120)
            corporation = @game.corporations.find { |c| c.id == 'GJ' }
            share_price = @game.stock_market.par_prices.min_by(&:price)

            @game.stock_market.set_par(corporation, share_price)
            corporation.ipoed = true

            shares = corporation.shares.first
            cost = share_price.price * 2
            actual_cost = [cost, player.cash].min

            @game.share_pool.transfer_shares(
              shares.to_bundle,
              player,
              spender: player,
              receiver: @game.bank,
              price: actual_cost
            )

            @log << "#{player.name} pars #{corporation.name} at #{@game.format_currency(share_price.price)} "\
                    "(forced by rule 6.3, pays #{@game.format_currency(actual_cost)})"

            @round.next_entity_index!
            setup_auction
          end

          def buy_company(player, company, _listed_price)
            price = company.value

            # Edge case: if player can't afford face value, pay what they can
            # (per manual: "must pay what they can for the cheapest Company")
            if player.cash < price
              price = player.cash
              @log << "#{player.name} cannot afford full price, pays #{@game.format_currency(price)}"
            end

            company.owner = player
            player.companies << company
            player.spend(price, @game.bank) if price.positive?
            @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

            # Trigger company abilities (P5 grants OE share, P3 grants influence cube)
            @game.after_buy_company(player, company, price)

            @companies.delete(company)
            @last_winner = player

            # P6: must immediately set par for GJ
            if company.sym == 'PGJ'
              # Rule 6.3: if all passed and player can't afford 2x min par, fix par at £60
              if @all_passed && !can_afford_p6?(player)
                force_par_gj(player)
              else
                @pending_par = player
              end
              @all_passed = false
              return
            end

            @all_passed = false
            @round.next_entity_index!
            setup_auction
          end
        end
      end
    end
  end
end
