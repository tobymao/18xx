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

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true
        COMPANY_SALE_FEE = 0 # Fee for selling Guillaume-Luxembourg to the bank.

        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :par

        MUST_BUY_TRAIN = :always # Just for majors, minors are handled in #must_buy_train?
        BANKRUPTCY_ALLOWED = true
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        def setup
          super

          setup_tokens
          @pledged_minors = major_corporations.to_h { |corp| [corp, nil] }
        end

        def next_round!
          @round =
            case @round
            when Round::Auction
              if @turn == 1
                init_round_finished
                reorder_players
              end
              new_stock_round
            when Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                major_auction_round
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
          Engine::Round::Auction.new(self, [
            G18Ardennes::Step::MajorAuction,
          ])
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G18Ardennes::Step::BuySellParSharesCompanies,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18Ardennes::Step::Track,
            G18Ardennes::Step::Token,
            G18Ardennes::Step::CollectForts,
            G18Ardennes::Step::Route,
            G18Ardennes::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end

        def operating_order
          minor_corporations.select(&:ipoed).sort +
          major_corporations.select(&:ipoed).sort
        end

        # Checks whether a player really is bankrupt.
        def can_go_bankrupt?(player, _corporation)
          return super if @round.is_a?(Round::Operating)

          # Has the player won the auction for a major company concession
          # that they cannot afford to start?
          bankrupt?(player)
        end
      end
    end
  end
end
