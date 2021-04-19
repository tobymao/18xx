# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'

module Engine
  module Game
    module G1840
      class Game < Game::Base
        include_meta(G1840::Meta)
        include Map
        include Entities

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        purple: '#A79ECD',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')

        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        CURRENCY_FORMAT_STR = '%d'

        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 16, 4 => 14, 5 => 13, 6 => 12 }.freeze

        STARTING_CASH = { 3 => 300, 4 => 260, 5 => 230, 6 => 200 }.freeze

        ADDITIONAL_CASH = 350

        MARKET_TEXT = {
          par: 'City Corporation Par',
          par_2: 'Major Corporation Par',
        }.freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :red,
          par_2: :green,
        ).freeze

        PAR_RANGE = {
          city: [65, 75, 85, 95],
          major: [70, 80, 90, 100],
        }.freeze

        INITIAL_CITY_PAR = {
          'W' => 95,
          'V' => 85,
          'G' => 75,
          'D' => 65,
        }.freeze

        INITIAL_CITY_TOKENS = {
          'W' => [
            { coordinate: 'I1' },
            { coordinate: 'I9' },
            { coordinate: 'I15' },
            { coordinate: 'F24' },
          ],
          'V' => [
            { city_index: 1, coordinate: 'A17' },
            { coordinate: 'A13' },
            { coordinate: 'B10' },
            { coordinate: 'C7' },
            { coordinate: 'F6' },
            { coordinate: 'G3' },
          ],
          'G' => [
            { coordinate: 'A17' },
            { coordinate: 'D12' },
            { coordinate: 'I11' },
          ],
          'D' => [
            { city_index: 2, coordinate: 'A17' },
            { coordinate: 'D22' },
            { coordinate: 'E23' },
            { city_index: 1, coordinate: 'F24' },
          ],
        }.freeze

        def setup
          @first_stock_round = true
          @tram_corporations = @corporations.select { |item| item.type == :minor }
          @city_corporations = @corporations.select { |item| item.type == :city }
          @major_corporations = @corporations.select { |item| item.type == :major }
                                .sort_by { rand }.first(@players.size)

          @city_corporations.each do |corporation|
            par_value = INITIAL_CITY_PAR[corporation.id]
            price = @stock_market.par_prices.find { |p| p.price == par_value }
            @stock_market.set_par(corporation, price)
            corporation.ipoed = true

            initial_coordinates_info = INITIAL_CITY_TOKENS[corporation.id]

            initial_coordinates_info.each do |info|
              token = corporation.find_token_by_type
              city_index = info[:city_index] || 0
              hex_by_id(info[:coordinate]).tile.cities[city_index].place_token(corporation, token,
                                                                               check_tokenable: false)
            end
          end

          @corporations.clear
          @corporations.concat(@major_corporations)
          @corporations.concat(@city_corporations)
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1840::Step::SelectionAuction,
          ])
        end

        def stock_round
          if @first_stock_round
            @log << "Every Player receives #{format_currency(ADDITIONAL_CASH)} to par a corporation"
            @players.each { |item| @bank.spend(ADDITIONAL_CASH, item) }
            @first_stock_round = false
          end
          Engine::Round::Stock.new(self, [
            G1840::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def par_prices(corp)
          par_nodes = stock_market.par_prices
          available_par_prices = PAR_RANGE[corp.type]
          par_nodes.select { |par_node| available_par_prices.include?(par_node.price) }
        end

        def all_major_corporations_ipoed?
          @major_corporations.all?(&:ipoed)
        end

        def can_par?(corporation, parrer)
          super && corporation.type == :major
        end
      end
    end
  end
end
