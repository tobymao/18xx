# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 2.1: open auction of the private companies. In turn, a player opens an auction
        # for any remaining private (or passes); bids are multiples of $5 and must raise the previous bid
        # by at least $5 ($10 with the :bid_increment_10 option). If everyone passes in a row, one more
        # round is offered with the minimum bid at half the face value; if everyone passes again, the
        # remaining privates are removed from the game.
        class PrivateAuction < Engine::Step::Base
          include Engine::Step::PassableAuction

          ACTIONS = %w[bid pass].freeze

          attr_reader :companies

          def description
            'Private Company Auction'
          end

          def available
            @companies
          end

          def may_bid?(company)
            return false unless @companies.include?(company)

            super
          end

          def may_purchase?(_company)
            false
          end

          def active_entities
            return super unless auctioning

            winning_bid = highest_bid(auctioning)
            return [@active_bidders[0]] unless winning_bid

            next_index = (@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size
            [@active_bidders[next_index]]
          end

          # Granularity of the bids (the bid field steps by it); the minimum raise is in min_bid.
          def min_increment
            5
          end

          def min_bid(company)
            return unless company

            return forced_min_bid(company) if !@bids[company] || @bids[company].empty?

            highest_bid(company).price + @game.bid_increment
          end

          def max_bid(player, _company)
            player.cash
          end

          def actions(entity)
            return [] if @companies.empty?
            return [] unless entity == current_entity

            ACTIONS
          end

          def setup
            setup_auction
            @companies = @game.companies.reject(&:closed?).dup
            @consecutive_choosing_passes = 0
            @forced_round = false
          end

          def process_pass(action)
            entity = action.entity

            if auctioning
              pass_auction(entity)
              resolve_bids
            else
              @log << "#{entity.name} passes the auction choice"

              @consecutive_choosing_passes += 1

              if @consecutive_choosing_passes < entities.size
                @round.next_entity_index!
              elsif @forced_round
                @log << 'No player wanted to start another auction: the remaining Private Companies are removed from the game'
                @companies.each { |c| @game.remove_company(c) }
                @companies = []
              else
                @forced_round = true
                @consecutive_choosing_passes = 0
                @round.next_entity_index!
                @log << "#{entities[entity_index].name} may open an auction for at least half the value of a "\
                        'remaining Private Company'
              end
            end
          end

          def process_bid(action)
            validate_bid!(action)

            action.entity.unpass!

            if auctioning
              add_bid(action)
            else
              @consecutive_choosing_passes = 0
              was_forced = @forced_round
              selection_bid(action)
              @forced_round = false
              @log << "#{action.entity.name} uses the discount auction (half value)" if was_forced
            end
          end

          private

          # Checks the whole bid before any state is touched, so a rejected bid changes nothing.
          def validate_bid!(action)
            price = action.price
            raise GameError, 'The bid must have a price' unless price.is_a?(Numeric)
            raise GameError, 'Bids must be a multiple of $5' if price != price.to_i || (price % 5).nonzero?

            action.instance_variable_set(:@price, price.to_i)
            company = action.company
            raise GameError, 'The bid must be for a Private Company of the auction' unless company
            raise GameError, "#{company.name} is not available in the auction" unless @companies.include?(company)

            current = auctioning
            raise GameError, "Only #{current.name} can be bid on now" if current && company != current

            min = min_bid(company)
            raise GameError, "Minimum bid is #{@game.format_currency(min)} for #{company.name}" if action.price < min

            max = max_bid(action.entity, company)
            raise GameError, "Cannot afford bid. Maximum possible bid is #{max}" if action.price > max
          end

          def forced_min_bid(company)
            return company.min_bid unless @forced_round

            (company.min_bid / 10.0).ceil * 5
          end

          def add_bid(bid)
            super
            @log << "#{bid.entity.name} bids #{@game.format_currency(bid.price)} for #{bid.company.name}"
          end

          def win_bid(winner, company)
            player = winner.entity
            price = winner.price

            company.owner = player
            player.companies << company
            player.spend(price, @game.bank) if price.positive?
            @log << "#{player.name} wins the auction for #{company.name} with a bid of #{@game.format_currency(price)}"

            @companies.delete(company)
            winner_index = entities.index(player) || 0
            @round.entity_index = (winner_index + 1) % entities.size
          end
        end
      end
    end
  end
end
