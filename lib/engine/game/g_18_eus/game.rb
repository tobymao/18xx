# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'map'
# require_relative 'entities'

module Engine
  module Game
    module G18EUS
      class Game < Game::Base
        include_meta(G18EUS::Meta)
        include G18EUS::Entities
        include G18EUS::Map

        CERT_LIMIT = { 3 => 25, 4 => 20, 5 => 16 }.freeze

        STARTING_CASH = { 3 => 400, 4 => 300, 5 => 250 }.freeze

        MARKET = [
          %w[40 44 47 50p 53p 57p 61p 65p 70p 75p 80p 86p 92p 98p 105x 112x 120x 128x 137x 147x 157x 168z 180z 193z
             206z 221 236 253 270 289 310 331 354 379 406k 434k 465k 497k 532k 569k 609k 652k 700k 750e 800e],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par: 'Par available SR1+',
          par_1: 'Par available SR2+',
          par_2: 'Par available SR3+',
          ignore_sale_unless_pres: 'Stock price does not change on sale, unless by president',
          endgame: 'End game trigger'
        ).freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :yellow,
          par_1: :lightblue,
          par_2: :blue,
          ignore_sale_unless_pres: :violet,
          endgame: :red
        ).freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
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
            train_limit: 3,
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
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '4D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 100, rusts_on: '4', num: 20 },
          { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 10 },
          { name: '3', distance: 3, price: 250, rusts_on: '6', num: 10 },
          { name: '3+', distance: 3, price: 250, obsolete_on: '6', num: 1 },
          { name: '4', distance: 4, price: 400, rusts_on: '8', num: 5 },
          { name: '4+', distance: 4, price: 400, obsolete_on: '8', num: 1 },
          { name: '5', distance: 5, price: 600, num: 3 },
          { name: '6', distance: 6, price: 750, num: 3 },
          {
            name: '7',
            distance: 7,
            price: 850,
            num: 2,
            variants: [
              name: '3D',
              distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 }],
              price: 850,
            ],
          },
          {
            name: '4D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4, 'multiplier' => 2 }],
            price: 1100,
            num: 40,
            events: [{ 'type' => 'signal_end_game' }],
          },
        ].freeze

        POTENTIAL_RED_CITY_HEXES = [
          { hex_id: 'E7', RA: 3, RB: 0, RC: 1 },
          { hex_id: 'E11', RA: 3, RB: 5, RC: 2 },
          { hex_id: 'F4', RA: 3, RB: 1, RC: 2 },
          { hex_id: 'G7', RA: 3, RB: 4, RC: 3 },
          { hex_id: 'H6', RA: 3, RB: 1, RC: 3 },
          { hex_id: 'H12', RA: 3, RB: 4, RC: 0 },
          { hex_id: 'I9', RA: 3, RB: 4, RC: 3 },
        ].freeze

        POTENTIAL_METROPOLIS_HEXES = %w[D8 F8 F14 J8].freeze

        REVENUE_MARKERS = %w[
          yellow_10|green_20|brown_30|gray_40
          yellow_10|green_40|brown_70|gray_100
          yellow_20|green_30|brown_40|gray_50
          yellow_20|green_30|brown_40|gray_40
          yellow_20|green_40|brown_50|gray_60
          yellow_20|green_40|brown_50|gray_70
          yellow_20|green_40|brown_70|gray_100
          yellow_30|green_40|brown_50|gray_60
          yellow_30|green_40|brown_60|gray_80
          yellow_30|green_50|brown_60|gray_80
          yellow_30|green_50|brown_70|gray_90
          yellow_30|green_40|brown_50|gray_60
          yellow_40|green_50|brown_40|gray_30
          yellow_40|green_50|brown_60|gray_70
          yellow_10|green_20|brown_30|gray_40
          yellow_20|green_30|brown_40|gray_40
        ].freeze

        def setup
          setup_tiles
          randomize_setup
        end

        def setup_tiles
          @neutral_corp = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            logo: '18_eus/black',
            simple_logo: '18_eus/black',
            tokens: [],
          )
          @neutral_corp.owner = @bank

          tiles = %w[G11 L10].map { |hex_id| hex_by_id(hex_id).tile }
          # Put a neutral token on the first of each pair of red cities
          tiles += RED_CITY_TILE_NAMES.map { |tile_name| @tiles.find { |tile| tile.name == tile_name } }
          tiles.each do |tile|
            token = Token.new(@neutral_corp, price: 0, type: :neutral)
            @neutral_corp.tokens << token
            tile.cities.first.place_token(@neutral_corp, token, check_tokenable: false)
          end
        end

        def randomize_setup
          randomize_map
        end

        def randomize_map
          randomize_cities
          randomize_offboard_revenues
          randomize_subsidies
        end

        def randomize_cities
          red_city_tiles = @tiles.select { |tile| self.class::RED_CITY_TILE_NAMES.include?(tile.name) }
          red_city_tiles = red_city_tiles.sort_by { rand }.take(3)

          selected_cities = self.class::POTENTIAL_RED_CITY_HEXES.sort_by { rand }.take(3)
          selected_cities.each do |selected_city|
            hex = hex_by_id(selected_city[:hex_id])
            tile = red_city_tiles.shift
            rotation = selected_city[tile.name.to_sym]
            tile.rotate!(rotation)
            hex.lay(tile)
          end

          metropolis_hex = hex_by_id(self.class::POTENTIAL_METROPOLIS_HEXES.min_by { rand })
          metropolis_tile = @tiles.find { |tile| tile.name == self.class::METROPOLIS_TILE_NAME }
          metropolis_hex.lay(metropolis_tile)
        end

        def randomize_offboard_revenues
          markers = self.class::REVENUE_MARKERS.sort_by { rand }.dup
          @hexes.each do |hex|
            hex.tile.nodes.first.parse_revenue(markers.shift) if hex.tile.color == :red
          end
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: true)
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @final_operating_rounds || @phase.operating_rounds
              remove_subsidies if @turn == 1 && @round.round_num == 1
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_set_finished
                new_stock_round
              end
            end
        end

        def export_train
          turn = "#{@turn}.#{@round.round_num}"
          case turn
          when '1.1'
            @depot.export_all!('2')
          when '1.2'
            @depot.export_all!('2+')
            @phase.next! unless @phase.tiles.include?(:green)
          when '2.2'
            @depot.export_all!('3')
          else
            @depot.export! unless turn == '2.1'
          end
        end

        def init_round
          stock_round
        end

        def stock_round
          Round::Stock.new(self, [
            Step::DiscardTrain,
            Step::HomeToken,
            Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Step::Bankrupt,
            Step::Exchange,
            Step::SpecialTrack,
            Step::BuyCompany,
            Step::Track,
            Step::Token,
            Step::Route,
            Step::Dividend,
            Step::DiscardTrain,
            Step::BuyTrain,
            [Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def a8_revenue_marker
          @a8_revenue_marker ||= 'yellow_40|green_60|brown_80|gray_100'
        end

        #
        # Subsidies
        #
        def randomize_subsidies
          subsidy_hexes = @hexes.select do |hex|
            hex.tile.color == :white &&
            !hex.tile.cities.empty? &&
            hex.id != self.class::CHICAGO_HEX_ID
          end
          subsidy_tiles = subsidy_hexes.map(&:tile).sort_by { rand }.take(5)

          subsidies = self.class::SUBSIDIES.sort_by { rand }.take(subsidy_tiles.size)
          subsidy_tiles.zip(subsidies).each do |tile, subsidy|
            tile.icons << Engine::Part::Icon.new(subsidy['icon'])
          end
        end

        def claim_subsidy(corporation, hex)
          return unless (subsidy = @subsidies_by_hex.delete(hex.coordinates))

          hex.tile.icons.reject! { |icon| icon.name.include?('subsidy') }
          subsidy_company = create_company_from_subsidy(subsidy)
          subsidy_company.owner = corporation
          corporation.companies << subsidy_company
        end

        def create_company_from_subsidy(subsidy)
          company = Engine::Company.new(**subsidy)
          @companies << company
          update_cache(:companies)
          company
        end

        def apply_subsidy(corporation)
          return unless (subsidy = corporation.companies.first)

          if subsidy.value.positive?
            @log << "#{corporation.name} receives #{format_currency(subsidy.value)} from subsidy"
            @bank.spend(subsidy.value, corporation)
            subsidy.close!
          elsif subsidy.sym == 'S1'
            subsidy.owner.tokens.first.hex.tile.icons << Engine::Part::Icon.new('18_eus/plus_ten', 'plus_ten', true)
            subsidy.close!
          elsif subsidy.sym == 'S9'
            subsidy.all_abilities.each do |ability|
              ability.hexes << hex.id if ability.type == :tile_lay
              ability.corporation = corporation.id if ability.type == :close
            end
          end
        end

        def remove_subsidy(hex_id)
          hex_by_id(hex_id).tile.icons.reject! { |icon| icon.name.include?('subsidy') }
        end
      end
    end
  end
end
