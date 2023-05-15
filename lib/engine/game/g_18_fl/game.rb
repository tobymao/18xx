# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'round/operating'
require_relative '../cities_plus_towns_route_distance_str'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18FL
      class Game < Game::Base
        include_meta(G18FL::Meta)
        include CitiesPlusTownsRouteDistanceStr
        include Entities
        include Map

        register_colors(black: '#37383a',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 8000

        CERT_LIMIT = { 2 => 21, 3 => 15, 4 => 12 }.freeze

        STARTING_CASH = { 2 => 300, 3 => 300, 4 => 300 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        MARKET = [
          %w[60
             65
             70p
             75p
             80p
             90p
             100p
             110p
             125
             140
             160
             180
             200m
             225
             250
             275
             300
             330
             360
             400],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: { five_share: 2 },
            tiles: [:yellow],
            corporation_sizes: [5],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { five_share: 2, ten_share: 4 },
            tiles: %i[yellow green],
            corporation_sizes: [5],
            operating_rounds: 2,
            status: ['may_convert'],
          },
          {
            name: '4',
            on: '4',
            train_limit: { five_share: 1, ten_share: 3 },
            tiles: %i[yellow green],
            corporation_sizes: [5, 10],
            operating_rounds: 2,
            status: ['may_convert'],
          },
          {
            name: '5',
            on: '5',
            train_limit: { ten_share: 2 },
            tiles: %i[yellow green brown],
            corporation_sizes: [10],
            operating_rounds: 3,
            status: ['hotels_doubled'],
          },
          {
            name: '6',
            on: %w[6 3E],
            train_limit: { ten_share: 2 },
            tiles: %i[yellow green brown gray],
            corporation_sizes: [10],
            operating_rounds: 3,
            status: ['hotels_doubled'],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 5,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 200,
            rusts_on: '6',
            num: 4,
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 400,
            rusts_on: 'D',
            num: 3,
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 500,
            num: 2,
            events: [{ 'type' => 'close_companies' },
                     { 'type' => 'close_port' },
                     { 'type' => 'forced_conversions' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 600,
            variants: [
              {
                name: '3E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 },
                           {
                             'nodes' => ['town'],
                             'pay' => 99,
                             'visit' => 99,
                             'multiplier' => 0,
                           }],
                price: 600,
              },
            ],
            num: 7,
            events: [{ 'type' => 'hurricane' }],
          },
        ].freeze

        HOME_TOKEN_TIMING = :operating_round
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :left_block
        SELL_AFTER = :operate
        EBUY_OTHER_VALUE = true
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze
        STEAMBOAT_HEXES = %w[B5 B23 G20 K28].freeze
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'hurricane' => ['Florida Keys Hurricane', 'Track and hotels in the Florida Keys (M24, M26) is removed'],
          'close_port' => ['Port Token Removed'],
          'forced_conversions' => ['Forced Conversions',
                                   'All remaining 5 share corporations immediately convert to 10 share corporations']
        ).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(max_price: 'Maximum price for a 5-share corporation').freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'hotels_doubled' => ['Hotel Bonus Doubled', 'Hotel bonus increases from $10 to $20'],
          'may_convert' => ['Corporations May Convert',
                            'At the start of a corporations Operating turn it
                           may choose to convert to a 10 share corporation'],
        ).freeze

        SOLD_OUT_INCREASE = false
        ASSIGNMENT_TOKENS = {
          'POSC' => '/icons/1846/sc_token.svg',
        }.freeze
        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18FL::Step::BuySellParShares,
          ])
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18FL::Step::BuyCert,
          ])
        end

        def operating_round(round_num)
          G18FL::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18FL::Step::Assign,
            Engine::Step::Exchange,
            G18FL::Step::Convert,
            Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            G18FL::Step::Track,
            G18FL::Step::SpecialToken,
            G18FL::Step::Token,
            Engine::Step::Route,
            G18FL::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18FL::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_stock_market
          G18FL::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def steamboat
          @steamboat ||= company_by_id('POSC')
        end

        def tile_company
          @tile_company ||= company_by_id('TR')
        end

        def token_company
          @token_company ||= company_by_id('POSC')
        end

        def revenue_for(route, stops)
          revenue = super

          raise GameError, 'Route visits same hex twice' if route.hexes.size != route.hexes.uniq.size

          raise GameError, '3E must visit at least two paying revenue centers' if route.train.variant['name'] == '3E' &&
             stops.count { |h| !h.town? } <= 1

          steam = steamboat.id
          if route.corporation.assigned?(steam) && (port = stops.map(&:hex).find { |hex| hex.assigned?(steam) })
            revenue += 20 * port.tile.icons.count { |icon| icon.name == 'port' }
          end
          hotels = stops.count { |h| h.tile.icons.any? { |i| i.name == route.corporation.id } }

          # 3E doesn't count hotels.
          route.train.variant['name'] == '3E' ? revenue : revenue + (hotels * hotel_value)
        end

        def setup
          @corporations.each do |corporation|
            tile = hex_by_id(corporation.coordinates).tile
            tile.cities[corporation.city || 0].place_token(corporation, corporation.tokens.first, free: true)
          end
        end

        def hotel_value
          @phase.status.include?('hotels_doubled') ? 20 : 10
        end

        # Event logic goes here
        def event_close_port!
          @log << 'Port closes'
          removals = Hash.new { |h, k| h[k] = {} }

          @corporations.each do |corp|
            corp.assignments.dup.each do |company, _|
              removals[company][:corporation] = corp.name
              corp.remove_assignment!(company)
            end
          end

          @hexes.each do |hex|
            hex.assignments.dup.each do |company, _|
              removals[company][:hex] = hex.name
              hex.remove_assignment!(company)
            end
          end

          self.class::STEAMBOAT_HEXES.each do |hex|
            hex_by_id(hex).tile.icons.reject! { |icon| icon.name == 'port' }
          end

          removals.each do |company, removal|
            hex = removal[:hex]
            corp = removal[:corporation]
            @log << "-- Event: #{corp}'s #{company_by_id(company).name} token removed from #{hex} --"
          end
        end

        def corporation_opts
          two_player? && @optional_rules&.include?(:two_player_share_limit) ? { max_ownership_percent: 70 } : {}
        end

        def event_hurricane!
          @log << '-- Event: Florida Keys Hurricane --'
          key_west = @hexes.find { |h| h.id == 'M24' }
          key_island = @hexes.find { |h| h.id == 'M26' }

          @log << 'A hurricane destroys track in the Florida Keys (M24, M26)'
          key_island.lay_downgrade(key_island.original_tile)

          @log << 'The hurricane also destroys the hotels in Key West'
          key_west.tile.icons.clear
          key_west.lay_downgrade(key_west.original_tile)
        end

        # 5 => 10 share conversion logic
        def event_forced_conversions!
          @log << '-- Event: All 5 share corporations must convert to 10 share corporations immediately --'
          @corporations.select { |c| c.type == :five_share }.each { |c| convert(c, funding: c.share_price) }
        end

        def process_convert(action)
          @game.convert(action.entity)
        end

        def convert(corporation, funding: true)
          before = corporation.total_shares
          shares = @_shares.values.select { |share| share.corporation == corporation }

          corporation.share_holders.clear

          case corporation.type
          when :five_share
            shares.each { |share| share.percent = 10 }
            shares[0].percent = 20
            new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
            corporation.type = :ten_share
          else
            raise GameError, 'Cannot convert 10 share corporation'
          end

          shares.each { |share| corporation.share_holders[share.owner] += share.percent }

          new_shares.each do |share|
            add_new_share(share)
          end

          after = corporation.total_shares
          @log << "#{corporation.name} converts from #{before} to #{after} shares"
          if funding
            conversion_funding = 5 * corporation.share_price.price
            @log << "#{corporation.name} gets #{format_currency(conversion_funding)} from the conversion"
            @bank.spend(conversion_funding, corporation)
          end

          new_shares
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end
      end
    end
  end
end
