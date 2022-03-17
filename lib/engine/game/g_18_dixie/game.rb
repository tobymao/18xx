# frozen_string_literal: true

require_relative 'meta'
require_relative 'corporations'
require_relative 'tiles'
require_relative 'map'
require_relative 'market'
require_relative 'phases'
require_relative 'trains'
require_relative 'minors'
require_relative 'companies'
require_relative '../base'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G18Dixie
      class Game < Game::Base
        include_meta(G18Dixie::Meta)
        include G18Dixie::Tiles
        include G18Dixie::Map
        include G18Dixie::Market
        include G18Dixie::Phases
        include G18Dixie::Trains
        include G18Dixie::Companies
        include G18Dixie::Minors
        include G18Dixie::Corporations

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')

        include CitiesPlusTownsRouteDistanceStr

        # General Constants
        BANK_CASH = 12_000
        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12, 6 => 11 }.freeze
        CURRENCY_FORMAT_STR = '$%d'
        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :full_or }.freeze
        SELL_BUY_ORDER = :sell_buy_sell
        STARTING_CASH = { 3 => 700, 4 => 525, 5 => 425, 6 => 375 }.freeze
        TILE_RESERVATION_BLOCKS_OTHERS = true
        TRACK_RESTRICTION = :permissive

        # OR Constants
        FIRST_TURN_EXTRA_TILE_LAYS = [{ lay: true, upgrade: false }].freeze
        MAJOR_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze
        MINOR_TILE_LAYS = [{ lay: true, upgrade: true }].freeze

        def setup
          @recently_floated = []
          @minors.each do |minor|
            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)

            Array(minor.coordinates).each { |coordinates| hex_by_id(coordinates).tile.cities[0].add_reservation!(minor) }
          end
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18Dixie::Step::SelectionAuction,
          ])
        end

        def player_card_minors(player)
          minors.select { |m| m.owner == player }
        end

        def init_round_finished
          [M1_SYM, M2_SYM, M3_SYM, M4_SYM, M5_SYM, M6_SYM, M7_SYM, M8_SYM, M9_SYM, M10_SYM, M11_SYM, M12_SYM]
              .each { |m_id| make_minor_available(m_id) }
          first_player = %w[P1 P2 P3 P4 P5 P6 P7].filter_map { |p_id| company_by_id(p_id).owner }.first
          @log << "#{first_player.name} bought the lowest numbered private"
          @round.goto_entity!(first_player)
        end

        def timeline
          @timeline = [
            'End of ISR: Highest numbered remaining private is permanently closed',
            'SR1: Unsold ISR private companies* are available, Minors 1-12 are available for purcahse ',
            'End of OR 1.2: All unsold 2 trains are put in the open market',
            'SR2: Private companies 8-10 are available for auction Minor 13 is now available for purchase from the bank',
            'End of OR 2.1: Minors 1-4 are closed',
            'End of OR 2.2: Minors 5-8 are closed. Unsold private companies are put into open market for purchase in SR3',
            'End of SR3: All unsold Minors and Privates are closed',
            'End of OR 3.1: Minors 9-13 are closed',
          ].freeze
        end

        # OR Stuff
        def operating_round(round_num)
          Round::Operating.new(self, [
          Engine::Step::Bankrupt,
          Engine::Step::Exchange,
          Engine::Step::SpecialTrack,
          Engine::Step::BuyCompany,
          Engine::Step::Track,
          Engine::Step::Token,
          Engine::Step::Route,
          G18Dixie::Step::Dividend,
          Engine::Step::DiscardTrain,
          Engine::Step::BuyTrain,
          [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def or_round_finished
          @recently_floated = []
          turn = "#{@turn}.#{@round.round_num}"
          # Turn is X.Y where X is from the *following* OR, and Y is from the *preceding* OR. :(
          case turn
          when '2.2'
            @depot.reclaim_all!('2')
            make_minor_available(M13_SYM)
            %w[P8 P9 P10].each { |company_id| add_private(company_by_id(company_id)) }

          when '2.1'
            [M1_SYM, M2_SYM, M3_SYM, M4_SYM].each { |m_id| close_minor(m_id) }
          when '3.2'
            [M5_SYM, M6_SYM, M7_SYM, M8_SYM].each { |m_id| close_minor(m_id) }
            %w[P8 P9 P10].each { |company_id| put_private_in_pool(company_by_id(company_id)) }
          when '3.1'
            [M9_SYM, M10_SYM, M11_SYM, M12_SYM, M13_SYM].each { |m_id| close_minor(m_id) }
          end
        end

        def tile_lays(entity)
          operator = entity.company? ? entity.owner : entity
          extra_tile_lays = @recently_floated&.include?(operator) ? FIRST_TURN_EXTRA_TILE_LAYS : []
          if operator.corporation?
            extra_tile_lays + MAJOR_TILE_LAYS
          elsif operator.minor?
            extra_tile_lays + MINOR_TILE_LAYS
          else
            super
          end
        end

        def operating_order
          corporations = @corporations.select(&:floated?)
          if @turn == 1 && (@round_num || 1) == 1
            corporations.sort_by! do |c|
              sp = c.share_price
              [sp.price, sp.corporations.find_index(c)]
            end
          else
            corporations.sort!
          end
          @minors.select(&:floated?) + corporations
        end

        def close_minor(minor_id)
          minor = minor_by_id(minor_id)
          return if minor.closed?

          @log << "#{minor.name} closes"
          company_by_id(minor_id).close!
          minor.close!
        end

        # SR stuff
        def stock_round
          Round::Stock.new(self, [
          Engine::Step::DiscardTrain,
          Engine::Step::Exchange,
          Engine::Step::SpecialTrack,
          G18Dixie::Step::BuySellParShares,
          ])
        end

        def bidding_power(player)
          player.cash
        end

        def buyable_bank_owned_companies
          return super if !@round.respond_to?(:auctioning) || !@round.auctioning

          super.select { |c| @round.auctioning == c }
        end

        def sr_round_finished
          super
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          super
        end

        def make_minor_available(minor_id)
          minor_company = company_by_id(minor_id)
          minor_company.owner = @bank
          minor_company.add_ability(POOL_PRIVATE_ABILITY)
          @log << "Minor #{minor_id} is now available for purchase"
        end

        def add_private(entity)
          raise GameError "#{entity.name} is not a private" unless entity.company?

          @log << "#{entity.name} is available to be put up for auction"
          entity.owner = @bank
        end

        def must_auction_company?(company)
          !company.all_abilities.include?(POOL_PRIVATE_ABILITY)
        end

        def put_private_in_pool(entity)
          raise GameError "#{entity.name} is not a private" unless entity.company?

          auctionable_ability = entity.all_abilities.find { |a| a.description == AUCTIONABLE_PRIVATE_DESCRIPTION }
          entity.remove_ability(auctionable_ability) if auctionable_ability
          entity.add_ability(POOL_PRIVATE_ABILITY)
          @log << "#{entity.name} is available to be bought from the bank for face value"
          entity.owner = @bank
        end

        def float_minor(minor_id, owner)
          minor = minor_by_id(minor_id)
          minor.owner = owner
          minor.float!
          company_by_id(minor_id).close!
          @recently_floated << minor
        end
      end
    end
  end
end
