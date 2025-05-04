# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/auctioner'

module Engine
  module Game
    module G1848
      module Step
        class DutchAuction < Engine::Step::Base
          include Engine::Step::Auctioner

          attr_reader :companies

          # On your turn, must buy any private or reduce price of any private
          # Once you own a private, you may pass
          # if everything is reduced to minimum price, and nobody has bought a private, you must buy one
          # if any privates are left and everyone passes in a row, owned privates pay and auction continues
          # if someone has bought a private and everything is minimum, you can pass

          ACTIONS = %w[bid assign].freeze
          ACTIONS_WITH_PASS = %w[bid assign pass].freeze

          MIN_PRICES = {
            'P1' => 0,
            'P2' => 40,
            'P3' => 80,
            'P4' => 140,
            'P5' => 140,
            'P6' => 200,
          }.freeze

          def description
            "Buy a Company or Reduce its Price by #{@game.format_currency(5)}"
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
            action.entity.unpass!
            company = action.company
            price = company.min_bid
            buy_company(current_entity, company, price)
            @game.after_buy_company(current_entity, company, price)
            @round.next_entity_index!
          end

          def process_pass(action)
            entity = action.entity
            @log << "#{entity.name} passes"
            entity.pass!
            all_passed! if entities.all?(&:passed?)
            @round.next_entity_index!
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

          def may_reduce?(company)
            # Each private can be discounted a maximum of 6 times
            company.min_bid > MIN_PRICES[company.sym]
          end

          def actions(entity)
            return [] if @companies.empty? || !entity.player? || (entity != current_entity)

            entity.player.companies.empty? ? ACTIONS : ACTIONS_WITH_PASS
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

          protected

          def active_auction
            false
          end

          def all_passed!
            # Run a fake OR where all privates pay once
            @game.payout_companies
            @game.or_set_finished

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
