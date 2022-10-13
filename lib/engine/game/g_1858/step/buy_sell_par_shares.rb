# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_via_bid'

module Engine
  module Game
    module G1858
      module Step
        class BuySellParShares < Engine::Step::BuySellParSharesViaBid
          # Buy actions that will end a player's turn in the stock round.
          PURCHASE_ACTIONS = [Action::Bid, Action::BuyShares, Action::Par].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return %w[bid pass] if @auctioning
            return ['sell_shares'] if must_sell?(entity)
            return [] if bought?

            actions = []

            # Sell actions
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'exchange_private' if can_exchange_any?(entity)
            actions << 'convert' if can_convert_any?(entity)

            # Buy actions
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity)
            actions << 'bid' if can_bid_any?(entity)

            actions << 'pass' unless actions.empty?

            actions
          end

          def pass_description
            if @auctioning
              "Pass (on #{auctioning.id})"
            elsif @round.current_actions.empty?
              'Pass'
            else
              'Done'
            end
          end

          def bank_first?
            true # Show bank owned private companies before public companies
          end

          def process_par(action)
            super
            pass!
          end

          def convert_button_text
            'Convert to 10-share company'
          end

          def can_convert?(corporation)
            (corporation.owner == current_entity) && (corporation.type == :medium) &&
              corporation.floated? && !bought?
          end

          def can_convert_any?(_entity)
            @game.corporations.any? { |corporation| can_convert?(corporation) }
          end

          def process_convert(action)
            @game.convert!(action.corporation)
          end

          def can_exchange_any?(_entity)
            false # TODO: implement this
          end

          def can_start_auction?(_entity)
            false # TODO: implement this
          end

          def min_bid(company)
            if @auctioning
              highest_bid(company).price + min_increment
            else
              company.min_bid
            end
          end

          def max_bid(player, _company)
            return 0 unless @game.num_certs(player) < @game.cert_limit

            player.cash
          end

          def win_bid(winner, _company)
            player = winner.entity
            company = winner.company
            price = winner.price

            @log << "#{player.name} wins bid on #{company.name} for #{@game.format_currency(price)}"
            @game.purchase_company(player, company, price)
            @auctioning = nil

            # Player to the right of the person who started the auction is next to go.
            @round.next_entity_index!
          end

          def auctionable_companies
            @game.buyable_bank_owned_companies
          end

          def can_bid_any?(_player)
            # auctionable_companies.any? { |company| can_bid_company?(player, company) }
            # FIXME: this test determines if the player can afford to bid on any companies.
            # But the game breaks with this in the quick start mode, it can't handle being
            # thrown straight into a stock round with no possible actions. Setting the initial
            # round to a operating round does not work either.
            true
          end

          def can_bid_company?(player, company)
            (@auctioning.nil? || @auctioning == company) &&
            auctionable_companies.include?(company) &&
              (min_bid(company) <= player.cash)
          end
        end
      end
    end
  end
end
