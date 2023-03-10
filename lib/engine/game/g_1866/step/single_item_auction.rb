# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'
require_relative '../../../step/share_buying'

module Engine
  module Game
    module G1866
      module Step
        class SingleItemAuction < Engine::Step::Base
          include Engine::Step::PassableAuction
          include Engine::Step::ShareBuying

          attr_reader :companies

          def actions(entity)
            return [] if available.empty?
            if entity.company? && !choices_ability(entity).empty? && @auctioning && !player_bid?(entity.owner)
              return ['choose_ability']
            end
            return [] unless entity == current_entity

            actions = []
            actions << 'bid' if min_bid(@auctioning) <= entity.cash
            actions << 'par' if @auctioning && !player_bid?(entity)
            actions << 'pass'
            actions
          end

          def active_auction
            company = @auctioning
            bids = @bids[company]
            yield company, bids
          end

          def active_entities
            if @auctioning
              winning_bid = highest_bid(@auctioning)
              return [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]] if winning_bid
            end

            super
          end

          def auction_entity(entity)
            @auctioning = entity
            min = min_bid(@auctioning)
            @active_bidders, cannot_bid = initial_auction_entities.partition do |player|
              max_bid(player, @auctioning) >= min || can_buy_stockturn_token?(player) ||
                can_par_corporation?(player)
            end
            cannot_bid.each do |player|
              @game.log << "#{player.name} cannot bid, buy a stock turn token or par a corporation"\
                           " and is out of the auction for #{auctioning.name}"
              player.pass!
            end
            next_entity! if !@active_bidders.empty? && @auction_start_entity&.passed?
            resolve_bids
          end

          def auction_log(entity)
            privates_left = @companies
                              .map { |c| @game.class::COMPANY_SHORT_NAME[c.id] unless c.id == entity.id }
                              .compact
                              .sort
                              .join(', ')
            privates_left_str = "In alphabetical order, the following items remain to be auctioned: #{privates_left}."
            privates_left_str = 'Last one.' if privates_left.empty?
            @game.log << "#{entity.name} is up for auction. #{privates_left_str}"
            @auction_start_entity = entities[entity_index]
            auction_entity(entity)
          end

          def available
            return [] if @companies.empty?

            [@companies[0]]
          end

          def can_buy?(_entity, bundle)
            return unless bundle&.buyable

            true
          end

          def can_buy_stockturn_token?(player)
            return false if player_bid?(player)

            st_company = player.companies.find { |c| @game.stock_turn_token_company?(c) }
            !choices_ability(st_company).empty?
          end

          def can_par_corporation?(player)
            return false if player_bid?(player)

            !par_corporations(player).empty?
          end

          def check_remove_from_auction(bid_entity = nil)
            # Remove players who cannot afford the bid, buy a stock turn token or par corporation
            min = min_bid(@auctioning)
            passing = @active_bidders.reject do |player|
              (bid_entity && player == bid_entity) || max_bid(player, @auctioning) >= min ||
                can_buy_stockturn_token?(player) || can_par_corporation?(player)
            end
            passing.each do |player|
              @game.log << "#{player.name} cannot bid, buy a stock turn token or par a corporation"\
                           " and is out of the auction for #{auctioning.name}"
              remove_from_auction(player)
              player.pass!
            end
          end

          def choices_ability(entity)
            return {} if !entity.company? || (entity.company? && !@game.stock_turn_token_company?(entity))

            choices = {}
            operator = entity.company? ? entity.owner : entity
            if @game.stock_turn_token?(operator)
              get_par_prices(operator).sort_by(&:price).each do |p|
                par_str = @game.par_price_str(p)
                choices[par_str] = par_str
              end
            end
            choices
          end

          def description
            'Initial Auction Round'
          end

          def get_par_prices(entity, corp = nil)
            par_type = @game.phase_par_type
            @game.par_prices_sorted.select do |p|
              multiplier = corp ? 2 : 1
              p.types.include?(par_type) && (p.price * multiplier) <= entity.cash &&
                @game.can_par_share_price?(p, corp)
            end
          end

          def player_bid?(player)
            @bids[@auctioning].any? { |bid| bid.entity == player }
          end

          def may_purchase?(_company)
            false
          end

          def max_bid(player, _company)
            player.cash
          end

          def min_bid(company)
            return unless company
            return starting_bid(company) unless @bids[company].any?

            high_bid = highest_bid(company)
            (high_bid.price || company.min_bid) + min_increment
          end

          def next_entity!
            @round.next_entity_index!
            entity = entities[entity_index]
            next_entity! if entity&.passed?
          end

          def pass_description
            if auctioning
              "Pass (on #{auctioning.name})"
            else
              'Pass'
            end
          end

          def pass_entity(entity, silent = false)
            current_auctioning = @auctioning
            winning_bid = highest_bid(@auctioning)
            if silent
              remove_from_auction(entity)
            else
              pass_auction(entity)
            end
            return if winning_bid || current_auctioning != @auctioning || @active_bidders.size == initial_auction_entities.size

            entity.pass!
            next_entity!
          end

          def par_corporations(entity)
            return [] if !entity || !entity.player?

            @game.sorted_corporations.reject do |c|
              c.closed? || c.ipoed || !@game.corporation?(c) || get_par_prices(entity, c).empty?
            end
          end

          def process_choose_ability(action)
            entity = action.entity
            choice = action.choice
            share_price = nil
            get_par_prices(entity.owner).each do |p|
              next unless choice == @game.par_price_str(p)

              share_price = p
            end
            return unless share_price

            @game.purchase_stock_turn_token(entity.owner, share_price)
            @game.stock_turn_token_name!(entity)
            check_remove_from_auction if @auctioning
            pass_entity(entity.owner, true)
          end

          def process_par(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, entity)

            @game.stock_market.set_par(corporation, share_price)
            share = corporation.ipo_shares.first
            buy_shares(entity, share.to_bundle)
            @game.after_par(corporation)

            check_remove_from_auction if @auctioning
            pass_entity(entity, true)
          end

          def process_pass(action)
            pass_entity(action.entity)
          end

          def process_bid(action)
            add_bid(action)
          end

          def remove_company(company)
            @companies.delete(company)
            @log << if @game.class::NATIONAL_COMPANIES.include?(company.id)
                      "#{company.name} closes. It will form in phase 5"
                    elsif @game.class::MINOR_GERMANY_COMPANIES.include?(company.id)
                      "#{company.name} closes and is removed from the game. A share in Germany will be available "\
                        'when it forms'
                    elsif @game.class::MINOR_ITALY_COMPANIES.include?(company.id)
                      "#{company.name} closes and is removed from the game. A share in Italy will be available "\
                        'when it forms'
                    end
          end

          def setup
            setup_auction
            @companies = @game.companies.reject { |c| @game.stock_turn_token_company?(c) }

            auction_log(@companies[0]) unless @companies.empty?
          end

          def show_stock_market?
            true
          end

          def starting_bid(company)
            @game.class::COMPANY_STARTING_BID[company.id]
          end

          private

          def add_bid(bid)
            company = bid.company
            entity = bid.entity
            price = bid.price
            min = min_bid(company)
            raise GameError, "Minimum bid is #{@game.format_currency(min)} for #{company.name}" if price < min
            if must_bid_increment_multiple? && ((price - min) % @game.class::MIN_BID_INCREMENT).nonzero?
              raise GameError, "Must increase bid by a multiple of #{@game.class::MIN_BID_INCREMENT}"
            end
            if price > max_bid(entity, company)
              raise GameError, "Cannot afford bid. Maximum possible bid is #{max_bid(entity, company)}"
            end

            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"
            bids = @bids[company]
            bids.reject! { |b| b.entity == entity }
            bids << bid

            check_remove_from_auction(bid.entity) if @auctioning
            resolve_bids
          end

          def post_win_bid(_winner, _company)
            entities.each(&:unpass!)
            @round.goto_entity!(@auction_start_entity)
            next_entity!

            auction_log(@companies[0]) unless @companies.empty?
          end

          def win_bid(winner, company)
            if winner
              player = winner.entity
              company = winner.company
              price = winner.price
              if @game.class::NATIONAL_COMPANIES.include?(company.id)
                company.owner = player
                player.companies << company
              elsif @game.class::MINOR_COMPANIES.include?(company.id)
                minor_id = @game.class::MINOR_COMPANY_CORPORATION[company.id]
                minor = @game.corporation_by_id(minor_id)

                par_rows = @game.class::MINOR_NATIONAL_PAR_ROWS[minor_id]
                share_price = @game.stock_market.share_price([par_rows[0], par_rows[1]])

                # Find the right spot on the stock market
                @game.stock_market.set_par(minor, share_price)

                # Select the president share to get
                share = minor.ipo_shares.first

                # Move all to the market
                bundle = ShareBundle.new(minor.shares_of(minor))
                @game.share_pool.transfer_shares(bundle, @game.share_pool)

                # Buy the share from the bank
                @game.share_pool.buy_shares(player,
                                            share.to_bundle,
                                            exchange: :free,
                                            exchange_price: share.price_per_share)
              end
              player.spend(price, @game.bank) if price.positive?
              @companies.delete(company)
              @log << "#{player.name} wins the auction for #{company.name} with a bid of #{@game.format_currency(price)}"
            else
              remove_company(company)
            end
          end
        end
      end
    end
  end
end
