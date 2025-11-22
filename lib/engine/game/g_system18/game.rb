# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

require_relative 'map_base_customization'
require_relative 'map_neus_customization'
require_relative 'map_france_customization'
require_relative 'map_twisting_tracks_customization'
require_relative 'map_uk_limited_customization'
require_relative 'map_china_rapid_development_customization'
require_relative 'map_poland_customization'
require_relative 'map_britain_customization'
require_relative 'map_northern_italy_customization'
require_relative 'map_ms_customization'
require_relative 'map_scotland_customization'
require_relative 'map_russia_customization'
require_relative 'map_gotland_customization'

module Engine
  module Game
    module GSystem18
      class Game < Game::Base
        include_meta(GSystem18::Meta)
        include Entities
        include Map

        include MapBaseCustomization
        include MapNeusCustomization
        include MapFranceCustomization
        include MapTwistingTracksCustomization
        include MapUKLimitedCustomization
        include MapChinaRapidDevelopmentCustomization
        include MapPolandCustomization
        include MapBritainCustomization
        include MapNorthernItalyCustomization
        include MapMsCustomization
        include MapScotlandCustomization
        include MapRussiaCustomization

        attr_accessor :deferred_rust, :merging, :merge_a_city, :merge_b_city

        include MapGotlandCustomization

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')

        MARKET_2D = [
          %w[75
             80
             90
             100p
             110
             125
             140
             160
             180
             200
             220
             250
             275],
          %w[70
             75
             80
             90p
             100
             110
             125
             140
             160
             180
             200
             220
             250],
          %w[65y
             70
             75
             80p
             90
             100
             110
             125
             140
             160
             180
             200
             220],
          %w[60y
             65
             70
             75p
             80
             90
             100
             110
             125
             140],
          %w[55y
             60y
             65
             70p
             75
             80
             90
             100],
          %w[50o
             60y
             65
             65p
             70
             75
             80],
          %w[45o
             55y
             60y
             65
             65
             70],
          %w[40b
             50o
             60y
             65y
             65],
          %w[30b
             40b
             50o
             60y],
          %w[20b
             30b
             40b
             50o],
        ].freeze

        MARKET_1D = [
          %w[40
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
             165
             180
             200
             220
             245
             270
             300
             330
             360
             400
             440
             490
             540
             600],
        ].freeze

        S18_TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 7 },
          { name: '3', distance: 3, price: 180, rusts_on: '6', num: 6 },
          { name: '4', distance: 4, price: 300, rusts_on: 'D', num: 5 },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 4,
          },
          { name: '6', distance: 6, price: 630, num: 3 },
          {
            name: '8',
            distance: 8,
            price: 800,
            num: 5,
          },
          {
            name: 'D',
            distance: 999,
            price: 900,
            num: 5,
            discount: { '4' => 200, '5' => 200, '6' => 200 },
          },
        ].deep_freeze

        S18_FULLCAP_PHASES = [
          { name: '2', train_limit: 3, tiles: [:yellow], operating_rounds: 1 },
          {
            name: '3',
            on: '3',
            train_limit: 3,
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
            train_limit: 2,
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
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].deep_freeze

        S18_INCCAP_PHASES = [
          { name: '2', train_limit: 3, tiles: [:yellow], operating_rounds: 2 },
          {
            name: '3',
            on: '3',
            train_limit: 3,
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
            train_limit: 2,
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
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].deep_freeze

        CURRENCY_FORMAT_STR = '$%s'
        MUST_SELL_IN_BLOCKS = false
        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = true
        HOME_TOKEN_TIMING = :operate
        GAME_END_CHECK = { bankrupt: :immediate, final_phase: :one_more_full_or_set }.freeze
        LAYOUT = :pointy
        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }].freeze
        EBUY_FROM_OTHERS = :never
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = true
        COLOR_SEQUENCE = %i[white yellow green brown gray].freeze
        SELL_BUY_ORDER = :sell_buy_sell
        SELL_AFTER = :first
        SELL_MOVEMENT = :down_share
        SOLD_OUT_INCREASE = true
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = false
        BANKRUPTCY_ENDS_GAME_AFTER = :one
        STATUS_TEXT = {}.freeze
        TILE_UPGRADES_MUST_USE_MAX_EXITS = [].freeze
        DISCARDED_TRAINS = :remove
        REMOVE_UNUSED_RESERVATIONS = false

        def find_map_name
          optional_rules&.find { |r| r.to_s.include?('map_') }&.to_s&.delete_prefix('map_')&.downcase
        end

        def map_name
          @map_name ||= find_map_name || 'base'
        end

        # Common map name
        # for now this only handles Britain_N and Britain_S
        def cmap_name
          return @map_name unless @map_name.include?('britain_')

          'britain'
        end

        def layout
          send("map_#{cmap_name}_layout")
        end

        def init_starting_cash(players, bank)
          cash = send("map_#{map_name}_game_cash")[players.size]
          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def init_cert_limit
          send("map_#{map_name}_game_cert_limit")[players.size]
        end

        def game_capitalization
          @game_capitalizaton ||= send("map_#{cmap_name}_game_capitalization")
        end

        def init_corporations(stock_market)
          game_corporations.map do |corporation|
            self.class::CORPORATION_CLASS.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: game_capitalization,
              **corporation.merge(corporation_opts(corporation)),
            )
          end
        end

        def find_corp(corps, sym)
          corps.find { |c| c[:sym] == sym }
        end

        def corporation_opts(corporation)
          two_player? && corporation[:type] != 'minor' ? { max_ownership_percent: 70 } : {}
        end

        def location_name(coord)
          @location_names ||= game_location_names

          @location_names[coord]
        end

        def game_market
          send("map_#{cmap_name}_game_market")
        end

        def find_train(trains, name)
          trains.find { |t| t[:name] == name }
        end

        def game_trains
          trains = []
          S18_TRAINS.each { |t| trains << t.dup }
          send("map_#{map_name}_game_trains", trains)
        end

        def init_train_handler
          return super unless respond_to?("map_#{map_name}_custom_depot")

          custom_depot = send("map_#{map_name}_custom_depot")
          trains = game_trains.flat_map do |train|
            Array.new((train[:num] || num_trains(train))) do |index|
              Train.new(**train, index: index)
            end
          end

          custom_depot.new(trains, self)
        end

        def game_phases
          phases = []
          proto = send("map_#{cmap_name}_game_phases")
          proto.each { |pp| phases << pp.dup }

          if respond_to?("map_#{cmap_name}_post_game_phases")
            phases = send("map_#{cmap_name}_post_game_phases", phases)
          else
            # change last phase based on train roster
            phases.last[:name] = game_trains.last[:name]
            phases.last[:on] = game_trains.last[:name]
          end

          phases
        end

        def half_dividend_by_map?
          return game_capitalization == :incremental unless respond_to?("map_#{cmap_name}_half_dividend")

          send("map_#{cmap_name}_half_dividend")
        end

        def share_price_change_for_dividend_as_full_cap_by_map?
          return game_capitalization == :full unless respond_to?("map_#{cmap_name}_share_price_change_for_dividend_as_full_cap")

          send("map_#{cmap_name}_share_price_change_for_dividend_as_full_cap")
        end

        def movement_type_at_emr_share_issue_by_map
          return :left_block unless respond_to?("map_#{cmap_name}_movement_type_at_emr_share_issue")

          send("map_#{cmap_name}_movement_type_at_emr_share_issue")
        end

        def init_bank
          if respond_to?("map_#{cmap_name}_init_bank")
            send("map_#{cmap_name}_init_bank")
          else
            Bank.new(99_999, log: @log, check: false)
          end
        end

        def bank_starting_cash
          init_bank.cash
        end

        def redef_const(const, value)
          mod = is_a?(Module) ? self : self.class
          mod.send(:remove_const, const) if mod.const_defined?(const)
          mod.const_set(const, value)
        end

        def setup
          if map_name == 'base'
            @log << '-- ||============================================================================'
            @log << '-- || WARNING: You have started System18 without choosing a map option!'
            @log << '-- ||          This "base" map is not intended to be playable.'
            @log << '-- ||============================================================================'
          end

          @deferred_rust = []

          ###################################################
          # Default constant overrides for most maps
          # (to be re-overridden if needed by specific maps)
          #
          redef_const(:CURRENCY_FORMAT_STR, '$%s')
          redef_const(:COLOR_SEQUENCE, %i[white yellow green brown gray])
          redef_const(:GAME_END_CHECK, { bankrupt: :immediate, final_phase: :one_more_full_or_set })
          redef_const(:TILE_LAYS, [{ lay: true, upgrade: true, cost: 0 }])
          redef_const(:EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST, true)
          redef_const(:REMOVE_UNUSED_RESERVATIONS, false)

          if game_capitalization == :incremental
            ######################################################
            # Default constant overrides for Incremental Cap maps
            #
            redef_const(:SELL_BUY_ORDER, :sell_buy)
            redef_const(:SELL_AFTER, :first)
            redef_const(:SELL_MOVEMENT, :left_block_pres)
            redef_const(:SOLD_OUT_INCREASE, true)
            redef_const(:MUST_EMERGENCY_ISSUE_BEFORE_EBUY, true)
            redef_const(:BANKRUPTCY_ENDS_GAME_AFTER, :all_but_one)
          else
            ######################################################
            # Default constant overrides for Full Cap maps
            #
            redef_const(:SELL_BUY_ORDER, :sell_buy_sell)
            redef_const(:SELL_AFTER, :first)
            redef_const(:SELL_MOVEMENT, :down_share)
            redef_const(:SOLD_OUT_INCREASE, true)
            redef_const(:MUST_EMERGENCY_ISSUE_BEFORE_EBUY, false)
            redef_const(:BANKRUPTCY_ENDS_GAME_AFTER, :one)
          end

          #################################################
          # Map-specific constant overrides
          #
          send("map_#{cmap_name}_constants")

          #################################################
          # Map-specific setup
          #
          return unless respond_to?("map_#{map_name}_setup")

          send("map_#{map_name}_setup")
        end

        def init_round
          return send("map_#{cmap_name}_init_round") if respond_to?("map_#{cmap_name}_init_round")

          return super unless game_companies.empty?

          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter = 1
          stock_round
        end

        def stock_steps
          return send("map_#{cmap_name}_stock_steps") if respond_to?("map_#{cmap_name}_stock_steps")

          [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            GSystem18::Step::BuySellParShares,
          ]
        end

        def stock_round
          return send("map_#{cmap_name}_stock_round") if respond_to?("map_#{cmap_name}_stock_round")

          GSystem18::Round::Stock.new(self, stock_steps)
        end

        def operating_steps
          if respond_to?("map_#{cmap_name}_operating_steps")
            send("map_#{cmap_name}_operating_steps")
          elsif game_companies.empty?
            [
              GSystem18::Step::Bankrupt,
              Engine::Step::Exchange,
              Engine::Step::SpecialTrack,
              Engine::Step::SpecialToken,
              Engine::Step::BuyCompany,
              Engine::Step::HomeToken,
              GSystem18::Step::Track,
              GSystem18::Step::Token,
              Engine::Step::Route,
              GSystem18::Step::Dividend,
              Engine::Step::DiscardTrain,
              GSystem18::Step::BuyTrain,
            ]
          else
            [
              GSystem18::Step::Bankrupt,
              Engine::Step::Exchange,
              Engine::Step::SpecialTrack,
              Engine::Step::SpecialToken,
              Engine::Step::BuyCompany,
              Engine::Step::HomeToken,
              GSystem18::Step::Track,
              GSystem18::Step::Token,
              Engine::Step::Route,
              GSystem18::Step::Dividend,
              Engine::Step::DiscardTrain,
              GSystem18::Step::BuyTrain,
              [Engine::Step::BuyCompany, { blocks: true }],
            ]
          end
        end

        def operating_round(round_num)
          GSystem18::Round::Operating.new(self, operating_steps, round_num: round_num)
        end

        def reorder_players
          return super unless respond_to?("map_#{cmap_name}_reorder_players")

          send("map_#{cmap_name}_reorder_players")
        end

        def next_round!
          return super unless respond_to?("map_#{cmap_name}_next_round!")

          send("map_#{cmap_name}_next_round!")
        end

        def emergency_issuable_bundles(entity)
          return [] if game_capitalization != :incremental
          return [] if entity.trains.any?
          return [] unless @depot.min_depot_train

          min_train_price = @depot.min_depot_price
          return [] if entity.cash >= min_train_price

          @corporations.flat_map do |corp|
            bundles = bundles_for_corporation(entity, corp)
            bundles.select! { |b| @share_pool.fit_in_bank?(b) }

            # Cannot issue more shares than needed to buy the train from the bank
            train_buying_bundles = bundles.select { |b| (entity.cash + b.price) >= min_train_price }
            if train_buying_bundles.size > 1
              excess_bundles = train_buying_bundles[1..-1]
              bundles -= excess_bundles
            end
            bundles
          end.compact
        end

        def upgrades_to_correct_color?(from, to, selected_company: nil)
          COLOR_SEQUENCE.index(to.color) == (COLOR_SEQUENCE.index(from.color) + 1)
        end

        def upgrade_ignore_num_cities(from)
          return false unless respond_to?("map_#{cmap_name}_upgrade_ignore_num_cities")

          send("map_#{cmap_name}_upgrade_ignore_num_cities", from)
        end

        def or_round_finished
          return super unless respond_to?("map_#{cmap_name}_or_round_finished")

          send("map_#{cmap_name}_or_round_finished")
        end

        def or_set_finished
          return super unless respond_to?("map_#{cmap_name}_or_set_finished")

          send("map_#{cmap_name}_or_set_finished")
        end

        def close_corporation(corporation, quiet: false)
          return super unless respond_to?("map_#{cmap_name}_close_corporation")

          send("map_#{cmap_name}_close_corporation", corporation)
        end

        def close_corporation_with_reset(corporation, quiet: false, reset: true)
          close_corporation(corporation, quiet: quiet)

          if reset
            corporation = reset_corporation(corporation)
            hex_by_id(corporation.coordinates).tile.add_reservation!(corporation, corporation.city)
            @corporations << corporation

            @log << "#{corporation.name} is now available to start"
          end

          return unless respond_to?("map_#{cmap_name}_close_corporation_extra")

          send("map_#{cmap_name}_close_corporation_extra", corporation)
        end

        def check_other(route)
          return super unless respond_to?("map_#{cmap_name}_check_other")

          send("map_#{cmap_name}_check_other", route)
        end

        def check_route_combination(routes)
          return super unless respond_to?("map_#{cmap_name}_check_route_combination")

          send("map_#{cmap_name}_check_route_combination", routes)
        end

        def post_lay_tile(entity, tile)
          return unless respond_to?("map_#{cmap_name}_post_lay_tile")

          send("map_#{cmap_name}_post_lay_tile", entity, tile)
        end

        def token_same_hex?(entity, hex, token)
          return false unless respond_to?("map_#{cmap_name}_token_same_hex?")

          send("map_#{cmap_name}_token_same_hex?", entity, hex, token)
        end

        def company_header(company)
          return super unless respond_to?("map_#{cmap_name}_company_header")

          send("map_#{cmap_name}_company_header", company)
        end

        def can_par?(corporation, entity)
          return super unless respond_to?("map_#{cmap_name}_can_par?")

          send("map_#{cmap_name}_can_par?", corporation, entity)
        end

        def float_corporation(corporation)
          return super unless respond_to?("map_#{cmap_name}_float_corporation")

          send("map_#{cmap_name}_float_corporation", corporation)
        end

        def after_par(corporation)
          return super unless respond_to?("map_#{cmap_name}_after_par")

          send("map_#{cmap_name}_after_par", corporation)
        end

        def tokener_check_connected(entity, city, hex)
          return true unless respond_to?("map_#{cmap_name}_tokener_check_connected")

          send("map_#{cmap_name}_tokener_check_connected", entity, city, hex)
        end

        def tokener_available_hex(entity, hex)
          return true unless respond_to?("map_#{cmap_name}_tokener_available_hex")

          send("map_#{cmap_name}_tokener_available_hex", entity, hex)
        end

        def revenue_for(route, stops)
          revenue = super

          return revenue unless respond_to?("map_#{cmap_name}_extra_revenue_for")

          revenue + send("map_#{cmap_name}_extra_revenue_for", route, stops)
        end

        def revenue_str(route)
          revenue_str = super

          return revenue_str unless respond_to?("map_#{cmap_name}_extra_revenue_str")

          revenue_str + send("map_#{cmap_name}_extra_revenue_str", route)
        end

        def extra_revenue(entity, routes)
          return super unless respond_to?("map_#{cmap_name}_extra_revenue")

          send("map_#{cmap_name}_extra_revenue", entity, routes)
        end

        def submit_revenue_str(routes, show_subsidy)
          return super unless respond_to?("map_#{cmap_name}_submit_revenue_str")

          send("map_#{cmap_name}_submit_revenue_str", routes, show_subsidy)
        end

        def timeline
          return super unless respond_to?("map_#{cmap_name}_timeline")

          send("map_#{cmap_name}_timeline")
        end

        def ipo_name(_corp)
          game_capitalization == :incremental ? 'Treasury' : 'IPO'
        end

        def issuable_shares(entity)
          return [] unless entity.operating_history.size > 1
          return [] unless entity.corporation?

          bundles_for_corporation(entity, entity)
            .select { |bundle| @share_pool.fit_in_bank?(bundle) }
        end

        def can_remove_icon?(entity)
          return false unless respond_to?("map_#{cmap_name}_can_remove_icon?")

          send("map_#{cmap_name}_can_remove_icon?", entity)
        end

        def icon_hexes(entity)
          return [] unless respond_to?("map_#{cmap_name}_icon_hexes")

          send("map_#{cmap_name}_icon_hexes", entity)
        end

        def remove_icon(entity, hex_id)
          return unless respond_to?("map_#{cmap_name}_remove_icon")

          send("map_#{cmap_name}_remove_icon", entity, hex_id)
        end

        def removable_icon_action_str
          return unless respond_to?("map_#{cmap_name}_removable_icon_action_str")

          send("map_#{cmap_name}_removable_icon_action_str")
        end

        def status_str(corporation)
          return super unless respond_to?("map_#{cmap_name}_status_str")

          send("map_#{cmap_name}_status_str", corporation)
        end

        def modify_tile_lay(entity, action)
          return action unless respond_to?("map_#{map_name}_modify_tile_lay")

          send("map_#{map_name}_modify_tile_lay", entity, action)
        end

        def pre_lay_tile_action(action, entity, tile_lay)
          return unless respond_to?("map_#{map_name}_pre_lay_tile_action")

          send("map_#{map_name}_pre_lay_tile_action", action, entity, tile_lay)
        end

        def place_home_token(corporation)
          return super unless respond_to?("map_#{cmap_name}_place_home_token")

          send("map_#{cmap_name}_place_home_token", corporation)
        end

        def home_token_locations(corporation)
          return super unless respond_to?("map_#{cmap_name}_home_token_locations")

          send("map_#{cmap_name}_home_token_locations", corporation)
        end

        def destinate(corporation)
          return super unless respond_to?("map_#{cmap_name}_destinate")

          send("map_#{cmap_name}_destinate", corporation)
        end

        # used by maps that destinate
        def destination_hex(corporation)
          ability = corporation.abilities.first
          hexes.find { |h| h.name == ability.hexes.first } if ability
        end

        def game_end_check_values
          return super unless respond_to?("map_#{cmap_name}_game_end_check_values")

          send("map_#{cmap_name}_game_end_check_values")
        end

        def rust?(train, purchased_train)
          !@deferred_rust.include?(train) && super
        end

        def rust_trains!(train, entity)
          return send("map_#{cmap_name}_rust_trains!", train, entity) if respond_to?("map#{cmap_name}_rust_trains!")

          trains.each do |t|
            next if !t.name.include?('*') || !rust?(t, train)

            @deferred_rust << t
          end

          super
        end

        def train_warranted?(train)
          return false unless respond_to?("map_#{cmap_name}_train_warranted?")

          send("map_#{cmap_name}_train_warranted?", train)
        end

        def operating_order
          return send("map_#{cmap_name}_operating_order") if respond_to?("map_#{cmap_name}_operating_order")

          @minors.select(&:floated?) +
            @corporations.select { |c| c.floated? && c.type == :minor }.sort +
            @corporations.select { |c| c.floated? && c.type != :minor }.sort
        end

        # borrowed from 1867
        def move_tokens(from, to)
          from.tokens.each do |token|
            new_token = to.next_token
            unless new_token
              new_token = Engine::Token.new(to)
              to.tokens << new_token
            end

            city = token.city
            token.remove!
            city.place_token(to, new_token, check_tokenable: false)
          end
        end

        # borrowed from 1867
        def move_assets(from, to)
          receiving = []

          if from.cash.positive?
            receiving << format_currency(from.cash)
            from.spend(from.cash, to)
          end

          companies = transfer(:companies, from, to).map(&:name)
          receiving << "companies (#{companies.join(', ')})" if companies.any?

          trains = transfer(:trains, from, to).map(&:name)
          receiving << "trains (#{trains})" if trains.any?

          receiving
        end

        # mostly borrowed from 1867
        def convert(player, corporation, minor)
          @stock_market.set_par(corporation, minor.share_price)
          share = corporation.shares.first
          @share_pool.buy_shares(player, share.to_bundle, exchange: :free)

          move_tokens(minor, corporation)
          receiving = move_assets(minor, corporation)

          close_corporation_with_reset(minor, reset: false)

          @log << "#{minor.name} converts into #{corporation.name} receiving #{receiving.join(', ')}"
        end

        def merge(player, corporation, minor_a, minor_b)
          @log << "Merging minors #{minor_a.id} and #{minor_b.id} into 10-share corporation #{corporation.id}"

          @merging = true
          @merge_a = minor_a
          @merge_b = minor_b
          @merge_corporation = corporation

          # After merge it is the sum of the two minors' share prices (rounded down)
          new_price = @stock_market.market.flatten.sort_by(&:price).reverse.find do |sp|
            sp.price <= (minor_a.share_price.price + minor_b.share_price.price)
          end

          @stock_market.set_par(corporation, new_price)
          share = corporation.shares.first
          @share_pool.buy_shares(player, share.to_bundle, exchange: :free)

          token_a = minor_a.tokens.first
          token_b = minor_b.tokens.first

          @merge_a_city = token_a.city
          @merge_b_city = token_b.city

          if token_a.hex == token_b.hex && token_a.city != token_b.city
            # special case: minors have tokens in different cities in same hex
            # - player needs to select which city gets the token

            @round.pending_tokens << {
              entity: corporation,
              hexes: [token_a.hex],
              token: corporation.find_token_by_type,
            }
            token_a.remove!
            token_b.remove!
          else
            # otherwise, corporation gets minor_a token
            # and then it gets minor_b token if it's in a different hex
            move_tokens(minor_a, corporation)
            if minor_b.tokens.map(&:hex).none? { |t| t && corporation.tokens.map(&:hex).include?(t) }
              move_tokens(minor_b, corporation)
            else
              token_b.remove!
            end

            finish_merge
          end
        end

        def finish_merge
          # tokens are taken care of at this point
          #
          receiving = move_assets(@merge_a, @merge_corporation)
          receiving.concat(move_assets(@merge_b, @merge_corporation))

          close_corporation_with_reset(@merge_a, reset: false)
          close_corporation_with_reset(@merge_b, reset: false)

          @log << "#{@merge_a.name} and #{@merge_b.name} merges into #{@merge_corporation.name} receiving #{receiving.join(', ')}"
          @merging = false
          @merge_a = nil
          @merge_b = nil
          @merge_corporation = nil
        end

        # for the moment, this is tailored for the Russia map
        def nationalize(entity, national)
          LOGGER.debug "nationalize(#{entity&.id}, #{national&.id})"
          return unless entity.corporation?

          # delete shares after giving share value to shareholders
          entity.share_holders.keys.each do |share_holder|
            if share_holder != entity && share_holder != @share_pool
              total = 0
              share_holder.shares_of(entity).each do |share|
                @bank.spend(share.price, share_holder)
                total += share.price
              end
              @log << "#{share_holder.name} receives #{format_currency(total)} for shares of #{entity.name}" if total.positive?
            end
            share_holder.shares_by_corporation.delete(entity)
          end

          # cash to bank, trains tossed out, privates closed
          entity.spend(entity.cash, @bank) if entity.cash.positive?
          entity.trains.each { |t| t.buyable = false }
          entity.companies.dup.each do |company|
            company.close!
            @log << "#{company.name} closes"
          end

          # delete shares in pool and marker from market
          @share_pool.shares_by_corporation.delete(entity)
          entity.share_price&.corporations&.delete(entity)
          @corporations.delete(entity)

          # move tokens if room in national and doesn't already have a token in the same hex
          # NOTE: this isn't robust - it only works for simple city revenues
          entity.tokens.select(&:city).sort_by { |t| t.city.max_revenue }.reverse_each do |token|
            new_token = national.next_token

            city = token.city
            hex = token.hex

            token.remove!

            next unless new_token
            next if national.tokens.any? { |t| t.hex == hex }

            city.place_token(national, new_token, check_tokenable: false)
            @log << "#{national.name} tokens #{hex.id}"
          end

          entity.close!
          @cert_limit = init_cert_limit
          @round.force_next_entity! if @round.current_entity == entity

          @log << "#{entity.name} has been nationalized"
        end

        def must_buy_train?(entity)
          return super unless respond_to?("map_#{cmap_name}_must_buy_train?")

          send("map_#{cmap_name}_must_buy_train?", entity)
        end

        def no_trains(entity)
          return unless respond_to?("map_#{cmap_name}_no_trains")

          send("map_#{cmap_name}_no_trains", entity)
        end

        def can_issue_shares_for_train?(entity)
          return false unless respond_to?("map_#{cmap_name}_can_issue_shares_for_train?")

          send("map_#{cmap_name}_can_issue_shares_for_train?", entity)
        end
      end
    end
  end
end
