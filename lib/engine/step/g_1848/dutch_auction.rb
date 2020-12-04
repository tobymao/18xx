# frozen_string_literal: true

require_relative '../base'
require_relative '../auctioner'

module Engine
  module Step
    module G1848
      class DutchAuction < Base
        include Auctioner

        attr_reader :companies

        # On your turn, must buy any private or reduce price of any private
        # Once you own a private, you may pass
        # if everything is reduced to minimum price, and nobody has bought a private, you must buy one
        # if any privates are left and everyone passes in a row, owned privates pay and auction continues
        # if someone has bought a private and everything is minimum, you can pass

        ACTIONS = %w[bid reduce].freeze
        ACTIONS_WITH_PASS = %w[bid reduce pass].freeze

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

        def process_reduce(action)
          action.entity.unpass!
          company = action.company
          company.discount += 5
          price = company.min_bid
          @log << "#{current_entity.name} reduces #{company.name} by £5 to #{@game.format_currency(price)}"
          @round.next_entity_index!
        end

        def may_reduce?(company)
          # Each private can be discounted a maximum of 6 times

          if company.name == "Melbourne & Hobson's Bay Railway Company" && company.min_bid.positive?
            true
          elsif company.name == 'Sydney Railway Company' && company.min_bid > 40
            true
          elsif company.name == 'Tasmanian Railways' && company.min_bid > 80
            true
          elsif company.name == 'The Ghan' && company.min_bid > 140
            true
          elsif company.name == 'Trans-Australian Railway' && company.min_bid > 140
            true
          elsif company.name == 'North Australian Railway' && company.min_bid > 200
            true
          else
            false
          end
        end

        def actions(entity)
          return [] if @companies.empty?
          return [] unless entity.player?

          actions = entity.player.companies.empty? ? ACTIONS : ACTIONS_WITH_PASS

          entity == current_entity ? actions : []
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
          # P1 can be reduced to free, so we disable `check_positive`
          player.spend(price, @game.bank, check_positive: false)
          @companies.delete(company)
          @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

          company.abilities(:share) do |ability|
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
