# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/auctioner'

module Engine
  module Game
    module G18Texas
      module Step
        class SimultaneousAuction < Engine::Step::Base
          include Engine::Step::Auctioner

          attr_reader :companies

          def actions(entity)
            return [] if !entity.player? || (entity != current_entity) || !bids_for_player(entity).empty?

            ['bid']
          end

          def auctioning
            nil
          end

          def description
            'Bid on Companies'
          end

          def available
            @companies
          end

          def skip!
            current_entity.pass!
            next_entity!
          end

          def next_entity!
            return all_passed! if entities.all?(&:passed?)

            @round.next_entity_index!
            entity = entities[entity_index]
            next_entity! if entity&.passed?
          end

          def process_bid(action)
            action.entity.pass!

            company = action.company
            price = action.price
            entity = action.entity
            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"

            # unpass previous bidder
            @bids[company].first&.entity&.unpass!
            replace_bid(action)
            next_entity!
          end

          def auctioneer?
            false
          end

          def min_increment
            @game.class::MIN_BID_INCREMENT
          end

          def setup
            setup_auction
            @companies = @game.companies.dup
          end

          def starting_bid(company)
            [0, company.value].max
          end

          def min_bid(company)
            return unless company

            return starting_bid(company) unless @bids[company].any?

            high_bid = highest_bid(company)
            (high_bid.price || company.min_bid) + min_increment
          end

          def may_purchase?(_company)
            false
          end

          def max_bid(player, _company)
            player.cash
          end

          private

          def win_bid(winner, _company)
            player = winner.entity
            company = winner.company
            price = winner.price
            company.owner = player
            player.companies << company

            player.spend(price, @game.bank) if price.positive?
            @game.after_buy_company(player, company, price)
            @companies.delete(company)
            @log <<
                "#{player.name} wins the auction for #{company.name} "\
                "with a bid of #{@game.format_currency(price)}"
          end

          def init_company_abilities
            @companies.each do |company|
              next unless (ability = abilities(company, :shares))

              real_shares = []
              ability.shares.each do |share|
                case share
                when 'random_president', 'first_president'
                  idx = share == 'first_president' ? 0 : rand % @corporations.size
                  corporation = @corporations[idx]
                  share = corporation.shares[0]
                  real_shares << share
                  company.desc = "Purchasing player takes a president's share (20%) of #{corporation.name} \
              and immediately sets its par value. #{company.desc}"
                  @log << "#{company.name} comes with the president's share of #{corporation.name}"
                when 'random_share'
                  corporations = ability.corporations&.map { |id| corporation_by_id(id) } || @corporations
                  corporation = corporations[rand % corporations.size]
                  share = corporation.shares.find { |s| !s.president }
                  real_shares << share
                  company.desc = "#{company.desc} The random corporation in this game is #{corporation.name}."
                  @log << "#{company.name} comes with a #{share.percent}% share of #{corporation.name}"
                else
                  real_shares << share_by_id(share)
                end
              end

              ability.shares = real_shares
            end
          end

          def all_passed!
            resolve_bids
            # Need to move entity round once more to be back to the priority deal player
            @round.next_entity_index!
            pass!
          end

          def resolve_bids
            @bids.keys.each { |company| win_bid(@bids[company].first, company) }
          end

          def committed_cash(player, _show_hidden = false)
            bids_for_player(player).sum(&:price)
          end
        end
      end
    end
  end
end
