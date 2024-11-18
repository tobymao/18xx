# frozen_string_literal: true

require_relative '../base'
require_relative '../stubs_are_restricted'
require_relative 'entities'
require_relative 'map'
require_relative 'market'
require_relative 'meta'
require_relative 'tiles'
require_relative 'trains'

module Engine
  module Game
    module G18Ardennes
      class Game < Game::Base
        include_meta(G18Ardennes::Meta)
        include StubsAreRestricted
        include Entities
        include Map
        include Market
        include Tiles
        include Trains

        # Minors that have been pledged in bids to start public companies.
        # Used by {Step::MajorAuction} to pass this information to
        # {Step::BuySellParSharesCompanies}. This is a hash whose keys are
        # the major corporations and the values are the minor corporations.
        attr_accessor :pledged_minors

        # Dummy corporations used for managing neutral tokens.
        attr_accessor :mine_corp, :port_corp

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true
        COMPANY_SALE_FEE = 0 # Fee for selling Guillaume-Luxembourg to the bank.

        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        SELL_MOVEMENT = :left_block_pres

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :par

        MUST_BUY_TRAIN = :always # Just for majors, minors are handled in #must_buy_train?
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        BANKRUPTCY_ALLOWED = true
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        # 4D trains can share track with other trains. Put them in their own
        # autoroute group so that the autorouter works correctly.
        TRAIN_AUTOROUTE_GROUPS = [['4D']].freeze

        # The maximum number of tokens a major can have on the map.
        LIMIT_TOKENS_AFTER_MERGER = 6

        def setup
          super

          setup_tokens
          setup_icons
          @pledged_minors = major_corporations.to_h { |corp| [corp, nil] }
        end

        def next_round!
          @round =
            case @round
            when G18Ardennes::Round::Auction
              major_auction_finished
              new_stock_round
            when Engine::Round::Auction
              init_round_finished
              reorder_players
              new_operating_round
            when G18Ardennes::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                if @phase.name == '2' || concession_companies.all?(&:closed?)
                  new_stock_round
                else
                  new_major_auction_round
                end
              end
            end
        end

        def init_round
          minor_auction_round
        end

        def minor_auction_round
          Engine::Round::Auction.new(self, [
            G18Ardennes::Step::HomeHexTile,
            G18Ardennes::Step::MinorAuction,
          ])
        end

        def major_auction_round
          G18Ardennes::Round::Auction.new(self, [
            G18Ardennes::Step::MajorAuction,
          ])
        end

        def new_major_auction_round
          @log << "-- #{round_description('Auction')} --"
          major_auction_round
        end

        def major_auction_finished
          return if restricted?

          # The coloured icons showing which public companies can be started
          # from each city are no longer needed.
          @cities.each do |city|
            city.slot_icons.clear
            city.tokens.each { |token| reset_token_icon(token) }
          end
        end

        def stock_round
          G18Ardennes::Round::Stock.new(self, [
            G18Ardennes::Step::Exchange,
            G18Ardennes::Step::ExchangeApproval,
            G18Ardennes::Step::DeclineTokens,
            G18Ardennes::Step::DeclineTrains,
            Engine::Step::DiscardTrain,
            G18Ardennes::Step::DeclineForts,
            G18Ardennes::Step::BuySellParSharesCompanies,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G18Ardennes::Step::Bankrupt,
            G18Ardennes::Step::Convert,
            G18Ardennes::Step::Exchange,
            G18Ardennes::Step::DeclineTokens,
            G18Ardennes::Step::DeclineTrains,
            G18Ardennes::Step::DeclineForts,
            G18Ardennes::Step::PostConversionShares,
            G18Ardennes::Step::IssueShares,
            G18Ardennes::Step::Track,
            G18Ardennes::Step::Token,
            G18Ardennes::Step::CollectForts,
            G18Ardennes::Step::Route,
            G18Ardennes::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18Ardennes::Step::BuyTrain,
          ], round_num: round_num)
        end

        def operating_order
          minor_corporations.select(&:ipoed).sort +
          major_corporations.select(&:ipoed).sort
        end

        def acting_for_entity(entity)
          return super unless entity == current_entity
          return super unless entity.corporation?
          return super unless entity.receivership?
          return super if entity.trains.empty?

          # A company in receivership is operating. Most of the steps in the
          # operating round are skipped, but someone needs to select routes
          # if the company has a train. To make this easy for the players, the
          # player who should select the routes is:
          # - The last player to operate a company in this round, or (if no
          #   player-owned companies have yet operated),
          # - The next player due to operate a company in this round, or (if
          #   all companies are in receivership),
          # - The player with priority deal.
          corps = @round.entities
          ix = @round.entity_index
          operated = corps.take(ix).reject(&:receivership?)
          unoperated = corps.drop(ix + 1).reject(&:receivership?)
          if ix.positive? && !operated.empty?
            super(operated.last)
          elsif !unoperated.empty?
            super(unoperated.first)
          else
            players.first
          end
        end

        def liquidity(player, emergency: false)
          return player.cash unless sellable_turn?

          super + player.companies.sum(&:value)
        end

        def can_buy_presidents_share_directly_from_market?(_corporation)
          true
        end

        # Checks whether a player really is bankrupt.
        def can_go_bankrupt?(player, _corporation)
          return super if @round.operating?

          # Has the player won the auction for a major company concession
          # that they cannot afford to start?
          bankrupt?(player)
        end

        def bankrupt!(player, cash_target)
          @log << "-- #{player.name} goes bankrupt and sells remaining shares --"
          bankrupt_sell_shares(player)
          bankrupt_sell_companies(player)
          bankrupt_transfer_cash(player, cash_target)
          declare_bankrupt(player)
        end

        # If a player has gone above 60% holding in a major (by exchanging
        # minors for shares) they don't have to sell back down.
        def can_hold_above_corp_limit?(_entity)
          true
        end

        def num_certs(player)
          # Don't count concession private companies.
          super - player.companies.count { |c| c.type == :concession }
        end

        def convert!(corporation)
          corporation.type = :'10-share'

          # Existing shares change from 20% to 10%.
          @_shares.values
                  .select { |share| share.corporation == corporation }
                  .each { |share| share.percent /= 2 }
          corporation.share_holders.transform_values! { |percent| percent / 2 }

          # Five new 10% shares are added to the corporation treasury.
          (5..9).each do |i|
            share = Share.new(corporation, percent: 10, index: i)
            corporation.shares_by_corporation[corporation] << share
            corporation.share_holders[corporation] += share.percent
            @_shares[share.id] = share
          end

          # Certificate limit might increase.
          old_limit = @cert_limit
          new_limit = init_cert_limit
          return if old_limit == new_limit

          @log << "Certificate limit increases to #{new_limit}."
        end

        # Shares that can be issued as part of a public company's operating
        # turn. This is not allowed on a public company's first turn.
        def issuable_shares(corporation)
          return [] unless corporation.corporation?
          return [] if corporation.type == :minor
          return [] if corporation.operating_history.empty?

          bundles_for_corporation(corporation, corporation).select do |bundle|
            @share_pool.fit_in_bank?(bundle)
          end
        end

        private

        def bankrupt_sell_companies(player)
          player.companies.each do |company|
            if company.type == :minor
              # The Guillaume-Luxembourg minor gets put into the open market.
              @log << "#{player.name} sells #{company.name} to the bank " \
                      "for #{format_currency(company.value)}."
              bank.spend(company.value, player)
              company.owner = @bank
            else
              # Concession – make available for another player to start
              # the public company.
              company.owner = nil
              @pledged_minors[corporation_by_id(company.id)] = nil
            end
          end
          player.companies.clear
        end

        def bankrupt_sell_shares(player)
          player.shares_by_corporation.each do |corporation, shares|
            next if shares.empty?

            bundle = bundles_for_corporation(player, corporation).last
            num = bundle.num_shares == 1 ? 'a share' : "#{bundle.num_shares} shares"
            msg = "#{player.name} sells #{num} of #{corporation.name} for " \
                  "#{format_currency(bundle.price)}."
            @share_pool.sell_shares(bundle, silent: true)

            # `SharePool.sell_shares` doesn't correctly handle selling the
            # president's certificate to the market when a player bankrupts.
            # The certificate is sold to the market, but the corporation's
            # president (owner) is not changed.
            if corporation.presidents_share.owner == @share_pool
              corporation.owner = @share_pool
              msg += " #{corporation.name} enters receivership."
            end

            @log << msg
          end
        end

        def bankrupt_transfer_cash(player, target)
          return unless player.cash.positive?

          target_name = target == @bank ? 'the bank' : target.name
          @log << "#{format_currency(player.cash)} is transferred from " \
                  "#{player.name} to #{target_name}."
          player.spend(player.cash, target)
        end
      end
    end
  end
end
