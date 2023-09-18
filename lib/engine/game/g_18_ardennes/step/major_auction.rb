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
          MIN_PRICE = 0

          def actions(entity)
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
            @concessions = @game.companies.select do |company|
              company.type == :concession && company.owner.nil?
            end
            # Hash showing which minors can be used to start a public company.
            # The public companies are the has keys, each value is an array of
            # minor companies.
            @eligible_minors = {}
            # Array of minor companies that are currently commited in a bid on
            # a major company.
            @pledged_minors = []
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
              .difference(@pledged_minors)
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
            # TODO: bids + 280 * number winning bids
            player.cash >= 280
          end

          def next_entity!
            return all_passed! if entities.all?(&:passed?)

            @round.next_entity_index!
            # # Skip any players who are unable to add a new bid.
            # next_entity! unless can_bid_any?(entities[entity_index])
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
            if @restricted.nil?
              @restricted = @game.corporations.none? do |corporation|
                corporation.floated && corporation.type != :minor
              end
            end
            @restricted
          end

          # Finds all the minors that can be used to start the public company
          # associated with the concession. If this isn't the first auction
          # round then any minor can be used.
          def eligible_minors(concession)
            @eligible_minors[concession] ||=
              @game.corporations.select do |corporation|
                next false if corporation.closed?
                next false unless corporation.type == :minor
                next true unless restricted?

                coords ||= concession_corporation(concession).coordinates
                corporation.placed_tokens
                           .map(&:hex)
                           .map(&:coordinates)
                           .intersect?(coords)
              end
          end

          # Associates a minor corporation to the concession for a major.
          # Any existing minor <-> concession associations are removed.
          def link_concession_minor(concession, minor)
            # This is a bit of a hack. The `corporations` array for an exchange
            # ability is supposed to be a list of shares the company can be
            # swapped for.  This initially contains the associated major
            # corporation, here we stick the minor onto the end of the array,
            # where it can be found in the next stock round. As the minor
            # corporations never have any buyable shares this won't affect
            # anything else.
            ability = concession.abilities.first
            # remove any existing minors
            old_bid = ability.corporations.slice(1..-1)
            @pledged_minors.delete(old_bid)
            ability.corporations << minor
            @pledged_minors << minor
          end
        end
      end
    end
  end
end
