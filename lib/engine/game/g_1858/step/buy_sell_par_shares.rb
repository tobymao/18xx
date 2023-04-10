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

            # Sell actions.
            # Exchanging a private company for a share certificate from the
            # company treasury is also a sell action, but this is handled
            # through the companies' abilities rather than these actions.
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'convert' if can_convert_any?(entity)

            # Buy actions.
            # Starting a public company by exchanging a private company for the
            # president's certificate is also a buy action, but this is handled
            # through the companies' abilities rather than these actions.
            actions << 'buy_shares' if can_buy_any?(entity) || can_exchange_any?(entity)
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

          def can_ipo_any?(entity)
            # Can't start a public company by directly buying its president's
            # certificate until the start of phase 5.
            super && @game.phase.status.include?('public_companies')
          end

          def can_convert?(corporation)
            (corporation.owner == current_entity) && (corporation.type == :medium) &&
              corporation.floated? && !bought?
          end

          def can_convert_any?(_entity)
            @game.corporations.any? { |corporation| can_convert?(corporation) }
          end

          def can_gain?(entity, share, exchange: false)
            return super unless exchange
            return false unless super

            # The default behaviour of an exchange ability for an unfloated
            # corporation is to be able to exchange for either a single share
            # or for the presidency if @game.exchange_for_partial_presidency
            # is set. We don't want to be able to exchange for a normal share,
            # so block this here.
            share.corporation.floated? || share.president
          end

          def can_exchange_for_share?(entity)
            @game.corporations.any? do |corporation|
              corporation.num_treasury_shares.positive? &&
                @game.corporation_private_connected?(corporation, entity)
            end
          end

          def can_exchange_for_presidency?(entity, player)
            return false if @game.turn == 1 # Can't exchange in first stock round.

            (@game.par_price(entity).price <= player.cash) &&
              !@game.corporations.all?(&:ipoed)
          end

          def can_exchange?(entity, player)
            entity.all_abilities.any? do |ability|
              next unless ability.type == :exchange

              if ability.corporations == 'ipoed'
                can_exchange_for_share?(entity)
              else
                can_exchange_for_presidency?(entity, player)
              end
            end
          end

          def can_exchange_any?(player)
            minors = @game.minors.select { |m| m.owner == player }
            (player.companies + minors).any? { |entity| can_exchange?(entity, player) }
          end

          def process_convert(action)
            @game.convert!(action.corporation)
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
            @acted = false
            @round.next_entity_index!
          end

          def auctionable_companies
            @game.buyable_bank_owned_companies
          end

          def can_bid_any?(player)
            auctionable_companies.any? { |company| can_bid_company?(player, company) }
          end

          def can_bid_company?(player, company)
            (!@auctioning || @auctioning == company) &&
              auctionable_companies.include?(company) &&
              (min_bid(company) <= player.cash)
          end

          def log_skip(entity)
            super if @round.current_actions.empty?
          end
        end
      end
    end
  end
end
