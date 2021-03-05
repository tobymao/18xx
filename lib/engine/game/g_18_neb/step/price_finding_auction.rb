# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/auctioner'

module Engine
  module Game
    module G18NEB
      module Step
        class PriceFindingAuction < Engine::Step::Base
          include Engine::Step::Auctioner

          attr_reader :companies

          # On your turn, must bid on a private or pass
          # if any privates are left and everyone passes in a row, privates with a bid are purchased, privates without a bid are reduced by standard deduction 
          # if everyone passes and all items have a bid, the auction ends.

          ACTIONS = %w[bid pass].freeze
          
          STANDARD_DEDUCTION = 10

          # TODO: grab min prices from companies
          MIN_PRICES = {
            'P1' => 20,
            'P2' => 40,
            'P3' => 70,
            'P4' => 100,
            'P5' => 130,
            'P6' => 175,
          }.freeze

          def description
            "Price Finding Auction on Private Companies"
          end

          def available
            @companies
          end

          def auctioneer?
            false
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          def pass_description
            'Pass'
          end

          def process_bid(action)
            company = action.company
            price = company.min_bid
            buy_company(current_entity, company, price)
            @round.next_entity_index!
          end

          def process_pass(action)
            entity = action.entity
            @log << "#{entity.name} passes"
            entity.pass!
            all_passed! if entities.all?(&:passed?)
            @round.next_entity_index!
          end

          def actions(entity)
            return [] if @companies.empty? || !entity.player? || (entity != current_entity)

            ACTIONS
          end

          def setup
            setup_auction
            @companies = @game.companies.sort_by(&:min_bid)
            @cheapest = @companies.first
          end

          def min_bid(company)
            return unless company

            company.value - company.discount
          end

          def may_purchase?(_company)
            true
          end

          def process_assign(action)
            action.entity.unpass!
            company = action.target
            company.discount += 5
            price = company.min_bid
            @log << "#{current_entity.name} reduces #{company.name} by #{@game.format_currency(5)}
                  to #{@game.format_currency(price)}"
            @round.next_entity_index!
          end

          def discount_company(company)
            company.discount += STANDARD_DEDUCTION
            price = company.min_bid
            @log << "#{current_entity.name} reduces #{company.name} by #{@game.format_currency(5)}
                  to #{@game.format_currency(price)}"
          end

          protected

          def active_auction
            false
          end

          def all_passed!
            # 1. Resolve Bids: companies with bids are purchased AND removed from auction
            # 2. Discount companies without bids
            # 3. Unpass all players
            # 2. End auction if companies have all been purchased.
            resolve_bids
            entities.each(&:unpass!)
          end

          def buy_company(player, company, price)
            company.owner = player
            player.companies << company
            # P1 can be reduced to free, so we disable `check_positive` in that case
            player.spend(price, @game.bank, check_positive: company.sym != 'P1')
            @companies.delete(company)
            @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

            @game.abilities(company, :share) do |ability|
              share = ability.share

              if share.president
                # TODO: - I think this isn't necessary since we must par CAR to 100
                @round.company_pending_par = company
              else
                @game.share_pool.buy_shares(player, share, exchange: :free)
              end
            end
          end
        end
      end
    end
  end
end
