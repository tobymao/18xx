# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_via_bid'

module Engine
  module Game
    module G1858
      module Step
        class BuySellParShares < Engine::Step::BuySellParSharesViaBid
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
            actions << 'bid' if can_bid?(entity) # can_start_auction?(entity)

            actions << 'pass' unless actions.empty?

            actions
          end

          def pass_description
            if @auctioning
              "Pass (on #{auctioning.id})"
            else
              'Pass'
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

          def can_convert_any?
            @game.corporations.any? { |corporation| can_convert?(corporation) }
          end

          def process_convert(action)
            @game.convert!(action.corporation)
          end

          def can_exchange_any?
            false # TODO: implement this
          end

          def can_start_auction?
            false # TODO: implement this
          end

          def min_bid(company)
            if @auctioning
              highest_bid(company).price + min_increment
            else
              company.value - company.discount
            end
          end

          def max_bid(player)
            return 0 unless @game.num_certs(player) < @game.cert_limit

            player.cash
          end

          def win_bid(winner, _company)
            player = winner.entity
            company = winner.company
            price = winner.price

            @log << "#{player.name} wins bid on #{company.name} for #{@game.format_currency(price)}"
            player.spend(price, @game.bank)

            player.companies << company
            company.owner = player

            # minor = @game.minors.find { |m| m.id == company.id }
            # minor.owner = player
            # minor.float!

            @auctioning = nil

            # Player to the right of the person who started the auction is next to go.
            @round.next_entity_index!
          end

          def can_bid?(_player)
            !bought?
            # FIXME: check that there is a company that the player can afford to bid on
          end

          def auctionable_companies
            @game.buyable_bank_owned_companies
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
