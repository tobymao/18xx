# frozen_string_literal: true

require_relative '../company_price_up_to_face'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module GSteamOverHolland
      class Game < Game::Base
        include_meta(GSteamOverHolland::Meta)
        include Entities
        include Map
        include CompanyPriceUpToFace

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :semi_restrictive
        SELL_BUY_ORDER = :sell_buy
        CURRENCY_FORMAT_STR = 'fl. %s'
        MUST_SELL_IN_BLOCKS = true
        SELL_MOVEMENT = :left_share

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 18, 3 => 16, 4 => 14, 5 => 12 }.freeze

        STARTING_CASH = { 2 => 600, 3 => 400, 4 => 300, 5 => 240 }.freeze

        OR_SETS = [2, 2, 2, 2, 2].freeze

        CAPITALIZATION = :incremental

        MARKET = [
          [
            { price: 50 },
            { price: 55 },
            { price: 60 },
            { price: 65, types: [:par] },
            { price: 70, types: [:par] },
            { price: 75, types: [:par] },
            { price: 80, types: [:par] },
            { price: 90, types: [:par] },
            { price: 100, types: [:par] },
            { price: 110, types: [:ignore_sale_unless_president] },
            { price: 125, types: [:max_one_drop_unless_president] },
            { price: 140, types: [:max_two_drops_unless_president] },
            { price: 160, types: [:ignore_sale_unless_president] },
            { price: 180, types: [:max_one_drop_unless_president] },
            { price: 210, types: [:max_two_drops_unless_president] },
            { price: 240, types: [:ignore_sale_unless_president] },
            { price: 270, types: [:max_one_drop_unless_president] },
            { price: 300, types: [:max_two_drops_unless_president] },
            { price: 330, types: [:ignore_sale_unless_president] },
            { price: 360, types: [:endgame] },
          ],
        ].freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :yellow, ignore_unless_president: :green).freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          ignore_unless_president: 'Price will not drop below these values in Stock Round unless president sells'
        ).freeze

        def setup_preround
          # randomize the private companies, choose an amount equal to player count, sort numerically
          @companies = @companies.shuffle.take(@players.size).sort_by(&:name)
          # puts "List of companies: #{@companies.inspect}"
          # record whether or not the shuffled companies include KO
          @ko_included = @companies.include?(@ko_company)
          # puts "setup_preround: #{@ko_included}"
        end

        def setup
          setup_company_price_up_to_face
          @or = 0
          # puts "setup: #{@ko_included}"
        end

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow] },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 5 },
                  { name: '3', distance: 3, price: 200, rusts_on: '5', num: 4 },
                  { name: '4', distance: 4, price: 300, rusts_on: '6', num: 3 },
                  {
                    name: '5',
                    distance: 3,
                    price: 400,
                    num: 3,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 500,
                    num: 6,
                    variants: [
                      {
                        name: '3E',
                        distance:
                          [
                            { 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 },
                            { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                          ],
                        price: 600,
                      },
                    ],
                  }].freeze

        def timeline
          @timeline ||= [
            'Game ends after OR 5.2!',
          ].freeze
          @timeline
        end

        def show_progress_bar?
          true
        end

        def progress_information
          base_progress = [
            { type: :PRE },
            { type: :SR },
            { type: :OR, name: '1.1' },
            { type: :OR, name: '1.2' },
            { type: :SR },
            { type: :OR, name: '2.1' },
            { type: :OR, name: '2.2' },
            { type: :SR },
            { type: :OR, name: '3.1' },
            { type: :OR, name: '3.2' },
            { type: :SR },
            { type: :OR, name: '4.1' },
            { type: :OR, name: '4.2' },
            { type: :SR },
            { type: :OR, name: '5.1' },
            { type: :OR, name: '5.2' },
          ]

          base_progress << { type: :End }
        end

        GAME_END_CHECK = { custom: :current_or, stock_market: :current }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'Fixed number of ORs',
          stock_market: 'Company reached the top of the market.',
        ).freeze

        GAME_END_REASONS_TIMING_TEXT = Base::EVENTS_TEXT.merge(
          full_or: 'Ends after the final OR set.',
          current: 'Ends after this OR.'
        ).freeze

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::SelectionAuction,
          ])
        end

        # This allows for the ledges that prevent price drops unless the president is selling
        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
          super

          num_shares = bundle.num_shares
          unless president_selling
            num_shares = 0 if corporation.share_price.type == :ignore_sale_unless_president
            num_shares = 1 if corporation.share_price.type == :max_one_drop_unless_president
            num_shares = 2 if corporation.share_price.type == :max_two_drops_unless_president
          end
          num_shares.times { @stock_market.move_down(corporation) } if selling_movement?(corporation)
        end

        def nrs_corp
          @nrs_corp ||= corporation_by_id('NRS')
        end

        def ko_company
          @ko_company ||= company_by_id('KO')
        end

        def ko_included?
          @ko_included
        end

        # def action_processed(action)
        #   case action
        #   when Action::Par
        #     if action.corporation == nrs_corp && @removed_companies.include?(company_by_id('KO'))
        #       bonus = action.share_price.price
        #       @bank.spend(bonus, nrs_corp)
        #       @log << "#{nrs_corp.name} receives a #{format_currency(bonus)} because "\
        #               'a player received a share of it in the Private Auction'
        #     end
        #   end
        # end
      end
    end
  end
end
