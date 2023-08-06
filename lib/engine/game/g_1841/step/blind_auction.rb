# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G1841
      module Step
        class BlindAuction < Engine::Step::WaterfallAuction
          MIN_BID = 20

          def actions(entity)
            return [] if @companies.empty?
            return ['blind_bid'] if entity == current_entity && @initial_bids < @game.players.size

            correct = false

            active_auction do |_company, bids|
              correct = next_bid(bids).entity == entity
            end

            correct || entity == current_entity ? ACTIONS : []
          end

          def setup
            setup_auction
            @companies = @game.companies.dup
            @cheapest = @companies.first
            @bidders = Hash.new { |h, k| h[k] = [] }
            @initial_bids = 0
            @bid_list = Hash.new { |h, k| h[k] = [] }
            @player_total = {}
            @player_bids = {}
          end

          def blind_choices(_entity)
            @companies
          end

          def blind_label(entity)
            entity.sym
          end

          def blind_max(entity)
            entity.cash
          end

          def validate_blind_bid(entity, bids)
            total = 0
            bids.each do |b|
              if b.positive? && b < MIN_BID
                raise GameError, "Non-zero bids must be a minimum of #{@game.format_currency(MIN_BID)}"
              end

              total += b
            end
            raise GameError, "Total bid cannot be more than  #{@game.format_currency(entity.cash)}" if total > entity.cash

            @player_total[entity] = total
          end

          def add_blind_bid(entity, company, price)
            return unless price.positive?

            bid = Action::Bid.new(entity, price: price, company: company)
            @bids[company] << bid
            @bidders[company] |= [entity]
          end

          def can_auction?(_company)
            true
          end

          def show_bids
            @log << 'Bids:'
            @companies.each do |c|
              @log << "#{c.sym}: #{@bid_list[c].join(' | ')}"
            end
          end

          def reorder_players
            current_order = @game.players.dup
            @game.players.sort_by! do |player|
              sort_values = [@player_total[player]]
              sort_values.concat(@player_bids[player])
              sort_values << current_order.index(player)
              sort_values
            end.reverse!
            @log << '-- New player order: --'
            @game.players.each.with_index do |p, idx|
              pd = idx.zero? ? ' - Priority Deal -' : ''
              @log << "#{p.name}#{pd}"
            end
          end

          def remove_nulls
            @companies.dup.each do |c|
              @companies.delete(c) if @bids[c].empty?
            end
          end

          def remove_winners_and_losers
            @companies.dup.each do |c|
              bids = @bids[c]
              prices = bids.map(&:price)
              highest = prices.max
              count = prices.count { |p| p == highest }
              if count == 1
                winning_bid = @bids[c].find { |bid| bid.price == highest }
                @bids.delete(c)
                buy_company(winning_bid.entity, c, highest)
                next
              end

              # remove any lower bids
              @bids[c].reject! { |b| b.price < highest }
            end
          end

          def process_blind_bid(action)
            entity = action.entity
            bids = action.bids
            validate_blind_bid(entity, bids)
            action.entity.unpass!

            @player_bids[entity] = bids
            bids.each.with_index do |b, idx|
              company = @companies[idx]
              @bid_list[company] << b
              add_blind_bid(entity, company, b)
            end
            @log << "#{entity.name} has placed bid"
            @round.next_entity_index!

            @initial_bids += 1
            return unless @initial_bids >= @game.players.size

            # done with blind bidding. Move to waterfall auction if needed
            show_bids
            remove_nulls
            remove_winners_and_losers
            reorder_players
            resolve_bids
          end

          def show_companies
            @initial_bids < @game.players.size
          end

          def show_bids?(_company)
            @initial_bids >= @game.players.size
          end

          def next_bid(bids)
            bids.min_by { |b| [b.price, @game.players.find_index(b.entity)] }
          end

          def active_entities
            active_auction do |_, bids|
              return [next_bid(bids).entity]
            end

            super
          end
        end
      end
    end
  end
end
