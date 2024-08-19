# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/auctioner'

module Engine
  module Game
    module G18Ardennes
      module Step
        class MajorAuction < Engine::Step::Base
          include Engine::Step::Auctioner
          ACTIONS = %w[bid pass].freeze

          # Minimum bid on a concession.
          MIN_PRICE = 0
          # Cash needed to start a public company at the lowest possible par
          # price (Fr140).
          MIN_STARTING_COST = 280

          def actions(entity)
            return [] if @concessions.empty?
            return [] unless entity.player?
            return [] unless entity == current_entity
            return [] unless can_bid_any?(entity)

            ACTIONS
          end

          def description
            'Bid on public companies'
          end

          def setup
            setup_auction
            @concessions = @game.concession_companies.reject(&:closed?)
            # Hash showing which minors can be used to start a public company.
            # The public companies are the hash keys, each value is an array of
            # minor companies.
            @eligible_minors = {}
            maybe_skip_entity!
          end

          def show_map
            true
          end

          def auctioning
            nil
          end

          def auctioneer?
            false
          end

          def may_purchase?(_company)
            false
          end

          def available
            @concessions
          end

          def min_bid(company)
            return unless company

            return MIN_PRICE if @bids[company].empty?

            high_bid = highest_bid(company)
            (high_bid.price || company.min_bid) + min_increment
          end

          def max_bid(player, _company)
            # TODO: must have enough cash + sellable shares left to float companies
            player.cash
          end

          def bid_choices(concession)
            eligible_minors(concession)
              .difference(@game.pledged_minors.values)
              .select { |minor| minor.owner == current_entity }
              .to_h { |minor| [minor, "Bid with M#{minor.id}"] }
          end

          def process_bid(action)
            player = action.entity
            concession = action.company
            minor = action.corporation
            price = action.price

            @log << "#{player.name} bids #{@game.format_currency(price)} " \
                    "for #{concession.id} with minor #{minor.id}"
            link_concession_minor(concession, minor)
            player.unpass!
            replace_bid(action)
            next_entity!
          end

          def process_pass(action)
            log_pass(action.entity)
            current_entity.pass!
            next_entity!
          end

          def skip!
            current_entity.pass!
            next_entity!
          end

          private

          def can_bid_any?(player)
            check_biddable(player) == :bid
          end

          def next_entity!
            return all_passed! if entities.all?(&:passed?)

            @round.next_entity_index!
            maybe_skip_entity!
          end

          # Skips a player who is unable to add a new bid.
          def maybe_skip_entity!
            player = entities[entity_index]
            biddable = check_biddable(player)
            return if biddable == :bid

            log_skip_player(player, biddable)
            player.pass!
            next_entity!
          end

          # Returns all the bids for a player where they are currently winning
          # an auction.
          def winning_bids(player)
            @bids.values.select { |bid| bid.first&.entity == player }.flatten
          end

          # Returns the concessions up for auctions where the player does not
          # already have the winning bid.
          def unbid_concessions(player)
            @concessions.reject do |concession|
              @bids[concession].first&.entity == player
            end
          end

          # Checks whether the player is able to place a bid on a public
          # company.
          # @param player [Player] The player to check whether they can bid.
          # @return [label] :bid if the player can legally place a bid, or
          #   another value (one of :cash, :certificates, :minor or :winning)
          #   if they are not allowed to bid.
          def check_biddable(player)
            if winning_all_concessions?(player)
              :winning
            elsif no_qualifying_minors?(player)
              :minors
            elsif not_enough_cash?(player)
              :cash
            elsif too_many_certificates?(player)
              :certificates
            else
              :bid
            end
          end

          # Check if the player is already winning all the auctions.
          def winning_all_concessions?(player)
            unbid_concessions(player).empty?
          end

          # Check if the player has no minors that can be used to place a bid
          # on a public company.
          def no_qualifying_minors?(player)
            @game.minor_corporations.none? do |minor|
              next false unless minor.president?(player)
              next false if @game.pledged_minors.value?(minor)

              unbid_concessions(player).any? do |concession|
                eligible_minors(concession).include?(minor)
              end
            end
          end

          # Check the player has enough liquidity.
          def not_enough_cash?(player)
            bids = winning_bids(player)
            @game.liquidity(player) < bids.sum(&:price) + cash_needed(bids.size + 1)
          end

          # The minimum cash is needed to start new public companies.
          def cash_needed(num_corporations)
            MIN_STARTING_COST * num_corporations
          end

          # Check the player has enough certificate slots. It is very, very
          # unlikely that this is ever going to be a problem, but starting a
          # new public company takes up one certificate slot and if the player
          # does not have enough certificate slots available for all the public
          # companies they win in the auction then they will go bankrupt.
          def too_many_certificates?(_player)
            # TODO: attempt to spot if this is going to be a problem. This is
            # going to be a bit tricky as a lot of things may or may not be
            # sellable when it comes to the stock round. Minor companies cannot
            # be sold (other than the GL which is always sellable). Public
            # company share certificates are sellable unless there is already
            # 50% of that company in the pool, or it is the president's
            # certificate, which is not sellable unless another player has at
            # least 20% of that company.
            false
          end

          # Logs the reason why a player isn't able to place a bid.
          # @param player [Player] The player who isn't able to bid.
          # @param reason [label] The value returned from {check_biddable}.
          def log_skip_player(player, reason)
            @log <<
              case reason
              when :cash
                bids = winning_bids(player)
                winning = bids.size
                liquidity = @game.liquidity(player) - bids.sum(&:price)
                "#{player.name} does not have enough money to place a bid. " \
                  "#{@game.format_currency(cash_needed(winning + 1))} would " \
                  "be needed to start #{winning + 1} public " \
                  "#{winning.zero? ? 'company' : 'companies'} but " \
                  "#{player.name}’s total liquidity is " \
                  "#{@game.format_currency(liquidity)} after paying for bids."
              when :certificates
                "#{player.name} does not have enough certificate slots to " \
                'place a bid. One extra slot is needed for each public ' \
                'company being started.'
              when :minors
                "#{player.name} does have any minor companies that could " \
                'be used to place a bid on a public company.'
              when :winning
                "#{player.name} already is leading the auctions on all " \
                'available public companies.'
              else
                raise GameError, 'Unknown reason for being unable to place a ' \
                                 "bid [#{reason}]"
              end
          end

          def all_passed!
            resolve_bids
            # Need to move entity round once more to be back to the priority deal player
            @round.next_entity_index!
            pass!
          end

          def resolve_bids
            @bids.each do |company, bids|
              next if bids.empty?

              win_bid(bids.first, company)
            end
          end

          def win_bid(winner, _company)
            player = winner.entity
            company = winner.company
            minor = @game.pledged_minors[concession_corporation(company)]
            price = winner.price
            company.owner = player
            player.companies << company

            player.spend(price, @game.bank) if price.positive?
            @game.after_buy_company(player, company, price)
            @log <<
                "#{player.name} wins the auction for #{company.name} "\
                "with a bid of #{@game.format_currency(price)} " \
                "and minor #{minor.id}"
          end

          def committed_cash(player, _show_hidden = false)
            bids_for_player(player).sum(&:price)
          end

          # Returns the corporation that a concession is associated with.
          def concession_corporation(concession)
            @game.corporation_by_id(concession.id)
          end

          # If no public companies have yet been started then there are
          # geographical restrictions on which minor companies can be used to
          # start a public company.
          def restricted?
            @restricted = @game.restricted? if @restricted.nil?
            @restricted
          end

          # Finds all the minors that can be used to start the public company
          # associated with the concession. If this isn't the first auction
          # round then any minor can be used.
          def eligible_minors(concession)
            @eligible_minors[concession] ||=
              @game.minor_corporations.select do |minor|
                qualifying_minor?(minor, concession)
              end
          end

          # Checks whether this minor can be used to place a bid for the public
          # company concession.
          def qualifying_minor?(minor, concession)
            return false if minor.closed?
            return true unless restricted?

            coords = Entities::PUBLIC_COMPANY_HEXES[concession.id]
            minor.placed_tokens.any? do |token|
              coords.include?(token.hex.coordinates) &&
                (token.hex != paris_hex ||
                 token.city == eligible_paris_city(concession))
            end
          end

          # Associates a minor corporation to the concession for a major.
          # Any existing minor <-> concession associations are removed.
          def link_concession_minor(concession, minor)
            @game.pledged_minors[concession_corporation(concession)] = minor
          end

          def paris_hex
            @paris_hex ||= @game.hex_by_id(Entities::PARIS_HEX)
          end

          # Finds the city in Paris that can be used to start a public company.
          # This is the western city for N, and the eastern city for E.
          def eligible_paris_city(concession)
            paris_hex.tile.cities[Entities::PARIS_CITIES[concession.id]]
          end
        end
      end
    end
  end
end
