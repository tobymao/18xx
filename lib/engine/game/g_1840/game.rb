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

        OPERATING_ROUND_NAME = 'Line'

        AVAILABLE_CORP_COLOR = '#c6e9af'

        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }, { lay: true, upgrade: true, cost: 0 }].freeze

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

        TILE_COST = 0

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

        PROGRESS_INFORMATION = [
          { type: :PRE },
          { type: :SR, name: '1' },
          { type: :CR, name: '1', value: '1x' },
          { type: :LR, name: '1a' },
          { type: :LR, name: '1b' },
          { type: :CR, name: '2', value: '1x' },
          { type: :SR, name: '2' },
          { type: :LR, name: '2a' },
          { type: :LR, name: '2b' },
          { type: :CR, name: '3', value: '1x' },
          { type: :SR, name: '3', value: '1x' },
          { type: :LR, name: '3a' },
          { type: :LR, name: '3b' },
          { type: :CR, name: '4', value: '2x' },
          { type: :SR, name: '4', value: '1x' },
          { type: :LR, name: '4a' },
          { type: :LR, name: '4b' },
          { type: :CR, name: '5', value: '3x' },
          { type: :SR, name: '5', value: '1x' },
          { type: :LR, name: '5a' },
          { type: :LR, name: '5b' },
          { type: :LR, name: '5c' },
          { type: :CR, name: '6', value: '10x' },
          { type: :End },
        ].freeze

        CITY_TRACK_EXITS = {
          # G
          'B16' => [1, 3],
          'B14' => [0, 4],
          'C13' => [0, 3],
          'D12' => [5, 3],
          'E13' => [0, 2],
          'F12' => [0, 3],
          'H12' => [0, 2],
          # V
          'B10' => [0, 3],
          'C9' => [1, 3],
          'D6' => [5, 3],
          'E7' => [0, 2],
          'F6' => [0, 3],
          'G5' => [1, 3],
          # D
          'B20' => [2, 5],
          'C21' => [2, 5],
          'D22' => [2, 5],
          'E23' => [2, 5],
          # W
          'G23' => [1, 3],
          'G21' => [1, 4],
          'G19' => [1, 4],
          'G17' => [0, 4],
          'H16' => [0, 3],
          'I15' => [1, 3],
          'I13' => [1, 4],
          'I9' => [1, 4],
          'I7' => [1, 4],
          'I5' => [1, 4],
          'I3' => [1, 4],
        }.freeze

        attr_reader :tram_corporations, :major_corporations, :tram_owned_by_corporation

        def setup
          @intern_cr_phase_counter = 0
          @cr_counter = 0
          @first_stock_round = true
          @or = 0
          @all_tram_corporations = @corporations.select { |item| item.type == :minor }
          @tram_corporations = @all_tram_corporations.reject { |item| item.id == '2' }.sort_by do
            rand
          end.first(@players.size + 1)
          @tram_corporations.each { |corp| corp.reservation_color = self.class::AVAILABLE_CORP_COLOR }
          @unavailable_tram_corporations = @all_tram_corporations - @tram_corporations
          @city_corporations = @corporations.select { |item| item.type == :city }
          @major_corporations = @corporations.select { |item| item.type == :major }
                                .sort_by { rand }.first(@players.size)

          @tram_owned_by_corporation = {}
          @major_corporations.each do |item|
            @tram_owned_by_corporation[item] = []
          end
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
            corporation.owner = @share_pool
            train = @depot.upcoming.find { |item| item.name == 'City' }
            @depot.remove_train(train)
            train.owner = corporation
            corporation.trains << train
          end

          @corporations.clear
          @corporations.concat(@major_corporations)
          @corporations.concat(@city_corporations)
          @corporations.concat(@tram_corporations)
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
          G1840::Round::Stock.new(self, [
            G1840::Step::BuySellParShares,
          ])
        end

        def init_company_round
          @round_counter += 1
          @intern_cr_phase_counter += 1
          @cr_counter += 1
          @log << "-- #{round_description('Company', nil)} --"
          new_company_operating_route_round
        end

        def new_operating_round(round_num = 1)
          @log << "-- #{round_description(self.class::OPERATING_ROUND_NAME, round_num)} --"
          @phase.next! if @or == 2 || @or == 6 || @or == 8
          @or += 1
          @round_counter += 1
          operating_round(round_num)
        end

        def new_company_operating_route_round(round_num)
          G1840::Round::CompanyOperating.new(self, [
            G1840::Step::Route,
            G1840::Step::Dividend,
            # TODO: Divident of major corporations
          ], round_num: round_num, no_city: false)
        end

        def new_company_operating_buy_train_round(round_num)
          G1840::Round::CompanyOperating.new(self, [
            G1840::Step::BuyTrain,
          ], round_num: round_num, no_city: true)
        end

        def new_company_operating_auction_round
          G1840::Round::Acquisition.new(self, [
            G1840::Step::InterruptingBuyTrain,
            G1840::Step::AcquisitionAuction,
          ])
        end

        def new_company_operating_switch_trains(round_num)
          G1840::Round::CompanyOperating.new(self, [
            G1840::Step::ReassignTrains,
          ], round_num: round_num, no_city: true)
        end

        def operating_round(round_num)
          G1840::Round::LineOperating.new(self, [
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            G1840::Step::TrackAndToken,
            Engine::Step::Route,
            G1840::Step::Dividend,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              if @cr_counter.zero?
                init_company_round
              else
                new_operating_round(@round.round_num)
              end
            when G1840::Round::CompanyOperating
              @intern_cr_phase_counter += 1
              if @intern_cr_phase_counter < 3
                new_company_operating_buy_train_round
              elsif @intern_cr_phase_counter < 4
                new_company_operating_auction_round
              elsif @cr_counter == 1
                new_operating_round(@round.round_num)
              else
                new_stock_round
              end
            when new_company_operating_auction_round.class
              new_company_operating_switch_trains
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                init_company_round
              end
            when init_round.class
              init_round_finished
              new_stock_round
            end
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

        def show_progress_bar?
          true
        end

        def progress_information
          self.class::PROGRESS_INFORMATION
        end

        def corporate_card_minors(corporation)
          @tram_owned_by_corporation[corporation] || []
        end

        def owning_major_corporation(corporation)
          @tram_owned_by_corporation.find { |_k, v| v.find { |item| item == corporation } }.first
        end

        def buy_tram_corporation(buying_corporation, tram_corporation)
          tram_corporation.ipoed = true
          tram_corporation.ipo_shares.each do |share|
            @share_pool.transfer_shares(
              share.to_bundle,
              share_pool,
              spender: share_pool,
              receiver: buying_corporation,
              price: 0,
              allow_president_change: false
            )
          end
          tram_corporation.owner = buying_corporation.owner
          @tram_owned_by_corporation[buying_corporation] << tram_corporation
          @tram_corporations.delete(tram_corporation)
        end

        def restock_tram_corporations
          count_new_tram_corporations = @players.size + 1 - @tram_corporations.size
          return if count_new_tram_corporations.zero?

          new_tram_corporations = @unavailable_tram_corporations.sort_by { rand }.first(count_new_tram_corporations)
          new_tram_corporations.each { |corp| corp.reservation_color = self.class::AVAILABLE_CORP_COLOR }
          @tram_corporations.concat(new_tram_corporations)
          @corporations.concat(new_tram_corporations)
          @unavailable_tram_corporations -= new_tram_corporations
        end

        def payout_companies
          return unless @intern_cr_phase_counter.zero?

          super
        end

        def place_home_token(corporation)
          super
          @graph.clear
        end

        def buying_power(entity, **)
          return 0 if entity.type == :city
          return entity.cash if entity.type == :major

          owning_major_corporation(entity).cash
        end

        def orange_framed?(tile)
          tile.frame&.color == '#ffa500'
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          if from.towns.empty? && from.cities.empty? && !to.towns.empty? && to.cities.empty? &&
            from.color == :white && to.color == :yellow
            return true
          end
          if orange_framed?(from) && from.towns.size == 1 &&
             to.towns.size == 2 && from.color == :yellow && to.color == :green
            return true
          end

          super
        end

        def needed_exits_for_hex(hex)
          CITY_TRACK_EXITS[hex.id]
        end
      end
    end
  end
end
