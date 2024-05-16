# frozen_string_literal: true

require_relative '../g_1817/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Hiawatha
      class Game < G1817::Game
        include_meta(G18Hiawatha::Meta)
        include G18Hiawatha::Entities
        include G18Hiawatha::Map

        attr_accessor :jlbc_home, :blocking_token

        CERT_LIMIT = { 3 => 15, 4 => 12, 5 => 10, 6 => 8 }.freeze

        STARTING_CASH = { 3 => 435, 4 => 325, 5 => 260, 6 => 220 }.freeze

        TRAIN_STATION_PRIVATE_NAME = 'US'
        MILWAUKEE_HEX = 'A7'
        GREAT_LAKES_D10_HEX = 'D10'
        ROCKFORD_HEX = 'E1'

        SEED_MONEY = 160
        SELL_AFTER = :any_time

        ALWAYS_BUY_TRAINS_AT_FACE_VALUE = true

        MARKET = [
          %w[0l
             0a
             0a
             0a
             45
             45
             50p
             55p
             60p
             65p
             70p
             80p
             90p
             100p
             110p
             120p
             135p
             150p
             165p
             180p
             200p
             220
             245
             270
             300
             330
             360
             400
             440
             490],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '2+',
            on: '2+',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [5, 10],
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, obsolete_on: '3', rusts_on: '4', num: 31 },
                  { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 3 },
                  {
                    name: '3',
                    distance: 3,
                    price: 250,
                    num: 10,
                    events: [{ 'type' => 'remove_blocking_token' }],
                  },
                  {
                    name: '4',
                    distance: 4,
                    price: 400,
                    num: 8,
                    events: [{ 'type' => 'signal_end_game' }],
                  }].freeze

        EVENTS_TEXT = G1817::Game::EVENTS_TEXT.merge(
          'remove_blocking_token' => ['Remove Blocking Token', "Blocking token in Milwaukee (#{MILWAUKEE_HEX}) is removed."],
          'signal_end_game' => ['Signal End Game', 'Game Ends at the end of the OR set after purchase/export of first 4 train.'],
        ).freeze

        ASSIGNMENT_TOKENS = {
          'farm' => '/icons/18_hiawatha/farm.svg',
          'GLS' => '/icons/18_hiawatha/port.svg',
          'FC' => '/icons/18_hiawatha/freight.svg',
        }.freeze

        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cannot_reuse_same_hex: true },
        ].freeze

        def setup_preround
          super
          @pittsburgh_private = @companies.find { |c| c.id == 'MB' }

          blocking_logo = '18_hiawatha/blocking'
          blocking_corp = Corporation.new(sym: 'B', name: 'blocking', logo: blocking_logo, simple_logo: blocking_logo,
                                          tokens: [0])
          blocking_corp.owner = @bank
          blocking_city = @hexes.find { |hex| hex.id == MILWAUKEE_HEX }.tile.cities.first
          token = blocking_corp.tokens[0]
          token.type = :blocking
          blocking_city.exchange_token(token)
          @blocking_token = token
        end

        def setup
          # rr_train is the reserved train for the Receivership Railroad private
          @rr_train = @depot.trains.find { |t| t.name == '2' }
          @depot.remove_train(@rr_train)
          @rr_train.reserved = true
        end

        def stock_round
          close_bank_shorts
          @interest_fixed = nil

          G1817::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G18Hiawatha::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @interest_fixed = nil
          @interest_fixed = interest_rate

          G18Hiawatha::Round::Operating.new(self, [
            G1817::Step::Bankrupt,
            G1817::Step::CashCrisis,
            G18Hiawatha::Step::Loan,
            G18Hiawatha::Step::SpecialTrack,
            G18Hiawatha::Step::Assign,
            G18Hiawatha::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1817::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1817::Step::BuyTrain,
          ], round_num: round_num)
        end

        def no_privates?
          @no_privates ||= @optional_rules&.include?(:no_privates)
        end

        # for the no privates variant
        def init_round
          no_privates? ? stock_round : new_auction_round
        end

        def size_corporation(corporation, size)
          corporation.second_share = nil

          return unless size == 10

          original_shares = @_shares.values.select { |share| share.corporation == corporation }

          corporation.share_holders.clear
          shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 1) }

          original_shares.each do |share|
            share.percent = share.president ? 20 : 10
            corporation.share_holders[share.owner] += share.percent
          end

          shares.each do |share|
            add_new_share(share)
          end
        end

        def tokens_needed(corporation)
          tokens_needed = { 5 => 2, 10 => 4 }[corporation.total_shares] - corporation.tokens.size
          tokens_needed += 1 if corporation.companies.any? { |c| c.id == TRAIN_STATION_PRIVATE_NAME }
          tokens_needed
        end

        def revenue_for(route, stops)
          revenue = super

          raise GameError, 'Route visits same hex twice' if route.hexes.size != route.hexes.uniq.size

          farm = 'farm'

          revenue += 10 * route.all_hexes.count { |hex| hex.assigned?(farm) }
          revenue += 10 if stops.any? { |stop| stop.hex.assigned?('GLS') }
          revenue += 10 if stops.any? { |stop| stop.hex.assigned?('FC') && route.corporation.assigned?('FC') }
          revenue += 20 if milwaukee_to_great_lakes_bonus?(stops)
          revenue += 40 if milwaukee_to_rockford_bonus?(stops)

          revenue
        end

        def revenue_str(route)
          str = super
          str += ' + Milwaukee-Great Lakes bonus (+20)' if milwaukee_to_great_lakes_bonus?(route.stops)
          str += ' + Milwaukee-Rockford bonus (+40)' if milwaukee_to_rockford_bonus?(route.stops)
          str
        end

        def milwaukee_to_great_lakes_hexes
          @milwaukee_to_great_lakes_hexes ||= %w[A7 D10].map { |id| hex_by_id(id) }
        end

        def milwaukee_to_rockford_hexes
          @milwaukee_to_rockford_hexes ||= %w[A7 E1].map { |id| hex_by_id(id) }
        end

        def milwaukee_to_great_lakes_bonus?(stops)
          stop_hexes = stops.map(&:hex)
          milwaukee_to_great_lakes_hexes.all? { |hex| stop_hexes.include?(hex) }
        end

        def milwaukee_to_rockford_bonus?(stops)
          stop_hexes = stops.map(&:hex)
          milwaukee_to_rockford_hexes.all? { |hex| stop_hexes.include?(hex) }
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return super unless selected_company == jlbc

          if to.color == :green &&
             from.hex.id == @jlbc_home &&
             upgrades_to_correct_label?(from, to) &&
             Engine::Tile::COLORS.index(to.color) > Engine::Tile::COLORS.index(from.color)
            true
          end
        end

        def check_other(route)
          return unless route.stops.any? do |stop|
                          stop.route_revenue(route.phase, route.train).zero? &&
                          !stop.hex.assigned?('GLS') &&
                          (!stop.hex.assigned?('FC') && !route.corporation.assigned?('FC'))
                        end

          raise GameError,
                'Cannot run to either of the Great Lakes hexes (D10, G13) for zero revenue.'
        end

        #  next two methods relate to the blocking token on Milwaukee and removing it in phase 3
        def event_remove_blocking_token!
          remove_blocking_token
        end

        def remove_blocking_token
          return unless blocking_token

          @log << "-- Event: Blocking token token removed from Milwaukee (#{MILWAUKEE_HEX}) --"
          blocking_token.destroy!
          @blocking_token = nil
        end

        # Private company definitions

        def muntzenberger_brewery
          @muntzenberger_brewery ||= company_by_id('MB')
        end

        def farmers_union
          @farmers_union ||= company_by_id('FU')
        end

        def great_lakes_shipping
          @great_lakes_shipping ||= company_by_id('GLS')
        end

        def freight_company
          @freight_company ||= company_by_id('FC')
        end

        def receivership_railroad
          @receivership_railroad ||= company_by_id('RR')
        end

        # this is the Jacob Leinenkugel Brewing Company. Name is just too long to use everywhere.
        def jlbc
          @jlbc ||= company_by_id('JLBC')
        end

        def postal_contract
          @postal_contract ||= company_by_id('PC')
        end

        # assigns Receivership Railroad train to owning corporation
        def assign_rr_train(company, corporation)
          if @phase.name == '4'
            @log << "#{company.owner.name} does not receive a train from the #{company.name}, "\
                    'as the 2-trains have already rusted!'
          else
            buy_train(corporation, @rr_train, :free)
            @log << "#{company.owner.name} receives a free 2-train from the #{company.name}."
          end
          company.close!
        end

        # assigns the home hex id of the acquiring corporation to the JLBC company
        def assign_jlbc_home_hex(company, corporation)
          @jlbc_home = corporation.tokens.first.city&.hex&.id
          company.all_abilities.each do |ability|
            ability.hexes << @jlbc_home
          end
        end

        def event_signal_end_game!
          game_end_check
          @log << "First 4 train bought/exported, ending game at the end of #{@turn + 1}.2"
        end
      end
    end
  end
end
