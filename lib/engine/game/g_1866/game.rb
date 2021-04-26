# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'

module Engine
  module Game
    module G1866
      class Game < Game::Base
        include_meta(G1866::Meta)
        include G1866::Entities
        include G1866::Map

        GAME_END_CHECK = { bank: :full_or, stock_market: :current_or }.freeze

        BANKRUPTCY_ALLOWED = false
        CURRENCY_FORMAT_STR = '£%d'
        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 42, 4 => 32, 5 => 25, 6 => 21, 7 => 18 }.freeze
        STARTING_CASH = { 3 => 800, 4 => 600, 5 => 480, 6 => 400, 7 => 340 }.freeze

        CAPITALIZATION = :incremental

        EBUY_OTHER_VALUE = false

        TILE_TYPE = :lawson
        LAYOUT = :pointy

        HOME_TOKEN_TIMING = :operate
        MUST_BID_INCREMENT_MULTIPLE = true
        MUST_BUY_TRAIN = :always
        NEXT_SR_PLAYER_ORDER = :least_cash

        MUST_SELL_IN_BLOCKS = false
        SELL_AFTER = :first
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_share

        MARKET = [
          %w[0 5 10 15 20 25 30p 35p 40p 45p 50p 55p 60x 65x 70x 75x 80x 90x 100z 110z 120z 135z 150w 165w 180
             200 220 240 260 280 300 330 360 390 420 460 500 540 580 630 680],
          %w[0 5 10 15 20 25 30p 35p 40p 45p 50p 55p 60p 65p 70p 75p 80x 90x 100x 110x 120z 135z 150z 165w 180w
             200 220 240 260 280 300 330 360 390 420 460 500 540 580 630 680],
          %w[0 5 10 15 20 25 30 35 40 45 50 55 60p 65p 70p 75p 80p 90p 100p 110x 120x 135x 150z 165z 180w
             200pxzw 220 240 260 280 300 330 360 390 420 460 500 540 580 630 680],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Yellow phase (L/2) par',
                                              par_1: 'Green phase (3/4) par',
                                              par_2: 'Brown phase (5/6) par',
                                              par_3: 'Gray phase (8/10) par').freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :yellow,
                                                            par_1: :green,
                                                            par_2: :brown,
                                                            par_3: :gray)

        PHASES = [
          {
            name: '1',
            on: '',
            train_limit: 5,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: %w[2 3],
            train_limit: 5,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
          {
            name: '10',
            on: '10',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: 'L',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 12,
            price: 50,
            rusts_on: '3',
            variants: [
              {
                name: '2',
                distance: 2,
                price: 100,
                rusts_on: '4',
                available_on: '1',
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            num: 6,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: 4,
            num: 6,
            price: 300,
            rusts_on: '8',
          },
          {
            name: '5',
            distance: 5,
            num: 6,
            price: 450,
            variants: [
              {
                name: '3E',
                distance: 3,
                multiplier: 2,
                price: 450,
              },
            ],
          },
          {
            name: '6',
            distance: 6,
            num: 6,
            price: 600,
            variants: [
              {
                name: '4E',
                distance: 4,
                multiplier: 2,
                price: 600,
              },
            ],
          },
          {
            name: '8',
            distance: 8,
            num: 6,
            price: 800,
            variants: [
              {
                name: '5E',
                distance: 5,
                multiplier: 2,
                price: 800,
              },
            ],
          },
          {
            name: '10',
            distance: 10,
            num: 20,
            price: 1000,
            variants: [
              {
                name: '6E',
                distance: 6,
                multiplier: 2,
                price: 1000,
              },
            ],
          },
        ].freeze

        # *********** 1866 Specific constants ***********
        NATIONAL_REGION_HEXES = {
          'G1' => %w[E23 E25 F20 F22 F24 F26 G15 G17 G19 G21 G23 G25 H14 H16 H18 H24 H26 I25],
          'G2' => %w[D18 E15 E17 E19 E21 F16 F18],
          'G3' => %w[I17 I19 J16 J18 J20 K17 K19 K21],
          'G4' => %w[I13 I15 J14 K15],
          'G5' => %w[H20 H22 I21 I23],
          'I1' => %w[S21 S23 T20 T22 T24 U21 V18 V20 W19],
          'I2' => %w[N12 O13 O15 S13 T12],
          'I3' => %w[M17 N14 N16 N18 N20 O17 P18],
          'I4' => %w[Q19 R18 R20 S19],
          'I5' => %w[P16 Q17],
          'AHN' => %w[J22 J24 J26 K23 K25 L18 L20 L22 L24 L26 M19 M21 M23 M25 N22 N24 N26 O21 O23 O25
                      P22 P24 P26 Q23 Q25 R24],
          'BMN' => %w[G9 G11 H10 H12],
          'FN' => %w[H6 H8 I1 I3 I5 I7 I9 J0 J2 J4 J6 J8 J10 J12 K1 K3 K5 K7 K9 K11 K13 L2 L4 L6 L8 L10
                     M3 M5 M7 M9 M11 N2 N4 N6 N8 N10 O3 O5 O7 O9 O11 P6 P8 P10 P12 Q13],
          'GBN' => %w[A3 B2 B4 C3 C5 D2 D4 D6 E1 E3 E5 E7 F2 F4 F6 G1 G3 G5],
          'NMN' => %w[E13 F10 F12 F14 G13],
          'SPMN' => %w[O1 P0 P2 P4 Q1 Q3 Q5 R0 R2 S1],
          'SWMN' => %w[L12 L14 L16 M13 M15],
          'LUXEMBOURG' => %w[I11],
          'AFRICA' => %w[W9],
          'AMERICA' => %w[C0],
        }.freeze

        PHASE_PAR_TYPES = {
          '1' => :par,
          '2' => :par,
          '3' => :par_1,
          '4' => :par_1,
          '5' => :par_2,
          '6' => :par_2,
          '8' => :par_3,
          '10' => :par_3,
        }.freeze

        REGION_CORPORATIONS = {
          'GREAT_BRITAIN' => %w[LNWR GWR NBR],
          'FRANCE' => %w[PLM MIDI OU],
          'GERMANY' => %w[KPS BY KHS],
          'AUSTRIA' => %w[SB BH FNR],
          'ITALY' => %w[SSFL IFT SFAI],
        }.freeze

        STOCK_TURN_TOKEN_PREFIX = 'ST'
        STOCK_TURN_TOKENS = {
          '3': 5,
          '4': 4,
          '5': 3,
          '6': 3,
          '7': 2,
        }.freeze

        # Corporations which will be able to float on which turn
        TURN_CORPORATIONS = {
          'ISR' => %w[ASC MSC GBN FN AHN LNWR GWR NBR PLM MIDI OU],
          'OR1' => %w[ASC MSC GBN FN AHN BMN NMN G1 G2 G3 G4 G5 I1 I2 I3 I4 I5 LNWR GWR NBR PLM MIDI OU KPS BY KHS
                      B GL NRS],
        }.freeze

        attr_accessor :current_turn

        def entity_can_use_company?(entity, company)
          entity == company.owner
        end

        def format_currency(val)
          return super if (val % 1).zero?

          format('£%.1<val>f', val: val)
        end

        def init_company_abilities
          @companies.each do |company|
            next unless (ability = abilities(company, :exchange))
            next unless ability.from.include?(:par)

            exchange_corporations(ability).first.par_via_exchange = company
          end

          super
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def next_round!
          @round =
            case @round
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
                new_stock_round
              end
            when init_round.class
              reorder_players_isr!
              stock_round_isr
            end
        end

        def new_auction_round
          Round::Auction.new(self, [
            G1866::Step::SelectionAuction,
          ])
        end

        def setup
          @stock_turn_token_per_player = self.class::STOCK_TURN_TOKENS[@players.size.to_s]
          @stock_turn_token_in_play = {}
          @player_setup_order = @players.dup
          @player_setup_order.each_with_index do |player, index|
            @log << "#{player.name} have stock turn tokens with number #{index + 1}"
            @stock_turn_token_in_play[player] = []
          end

          @current_turn = 'ISR'

          # Randomize and setup the corporations
          setup_corporations

          # Remove the stock turn
          setup_stock_turn_token
        end

        def sorted_corporations
          turn_corporations = self.class::TURN_CORPORATIONS[@current_turn]
          ipoed, others = if turn_corporations
                            @corporations.select { |c| turn_corporations.include?(c.name) }.partition(&:ipoed)
                          else
                            @corporations.partition(&:ipoed)
                          end
          ipoed.sort + others
        end

        def par_price_str(share_price)
          row, = share_price.coordinates
          row_str = case row
                    when 0
                      'T'
                    when 1
                      'M'
                    else
                      'B'
                    end
          "#{format_currency(share_price.price)}#{row_str}"
        end

        def phase_par_type
          self.class::PHASE_PAR_TYPES[@phase.name]
        end

        def place_starting_token(corporation, token, hex_coordinates)
          hex = hex_by_id(hex_coordinates)
          city = hex.tile.cities.first
          city.place_token(corporation, token, free: true, check_tokenable: false)
        end

        def purchase_stock_turn_token(player, share_price)
          index = @player_setup_order.find_index(player)
          corporation = Corporation.new(
            sym: 'ST',
            name: 'Stock Turn Token',
            logo: "1866/#{index + 1}",
            tokens: [],
            type: 'stock_turn_corporation',
            float_percent: 100,
            max_ownership_percent: 100,
            shares: [100],
            always_market_price: true,
            color: 'black',
            text_color: 'white',
            reservation_color: nil,
            capitalization: self.class::CAPITALIZATION,
          )

          @stock_market.set_par(corporation, share_price)
          player.spend(share_price.price, @bank)
          @stock_turn_token_in_play[player] << corporation
          @log << "#{player.name} buys a stock turn token at #{format_currency(share_price.price)}"
        end

        def reorder_players_isr!
          current_order = @players.dup

          # Sort on least amount of money
          @players.sort_by! { |p| [p.cash, current_order.index(p)] }

          # The player holding the P1 will become priority dealer
          p1 = @companies.find { |c| c.id == 'P1' }
          if p1
            @players.delete(p1.owner)
            @players.unshift(p1.owner)
            p1.close!
            @log << "#{p1.name} closes"
          end
          @log << "-- Priority order: #{@players.map(&:name).join(', ')}"
        end

        def setup_corporations
          # Randomize from preset seed to get same order
          corps = @corporations.select { |c| c.type == :major }.sort_by { rand }
          @removed_corporations = []

          # Select one of the three public companies based in each of GB, France, A-H, Germany & Italy
          starting_corps = []
          self.class::REGION_CORPORATIONS.each do |_, v|
            corp = corps.find { |c| v.include?(c.name) }
            starting_corps << corp
            corps.delete(corp)
          end

          # Include the next 8 corporations in the game, remove the last 7.
          corps.each_with_index do |c, index|
            if index < 8
              starting_corps << c
            else
              @removed_corporations << c
              @corporations.delete(c)
            end
          end

          # Put down the home tokens of all the removed corporations
          @removed_corporations.each do |corp|
            Array(corp.coordinates).each do |coord|
              token = Engine::Token.new(corp, logo: "/logos/1866/#{corp.name}_REMOVED.svg",
                                              simple_logo: "/logos/1866/#{corp.name}_REMOVED.svg",
                                              type: :removed)

              place_starting_token(corp, token, coord)
            end
            @log << "#{corp.name} - #{corp.full_name} is removed from the game"
          end
        end

        def setup_stock_turn_token
          # Give each player a stock turn company
          @players.each_with_index do |player, index|
            company = @companies.find { |c| c.id == "#{self.class::STOCK_TURN_TOKEN_PREFIX}#{index + 1}" }
            company.owner = player
            player.companies << company
          end

          # Remove the unused stock turn companies
          @companies.dup.each do |company|
            next if !stock_turn_token_company?(company) || company.owner

            @companies.delete(company)
          end
        end

        def stock_round_isr
          @log << '-- Initial Stock Round --'
          @round_counter += 1
          Round::Stock.new(self, [
            G1866::Step::BuySellParShares,
          ])
        end

        def stock_turn_token_company?(company)
          company.id[0..1] == self.class::STOCK_TURN_TOKEN_PREFIX
        end
      end
    end
  end
end
