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
        ].freeze

        S18_FULLCAP_PHASES = [
          { name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
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
        ].freeze

        S18_INCCAP_PHASES = [
          { name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 2 },
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
        ].freeze

        CURRENCY_FORMAT_STR = '$%s'
        MUST_SELL_IN_BLOCKS = false
        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = true
        HOME_TOKEN_TIMING = :operate
        GAME_END_CHECK = { bankrupt: :immediate, final_phase: :one_more_full_or_set }.freeze
        LAYOUT = :pointy
        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }].freeze
        EBUY_FROM_OTHERS = :never
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

        def find_map_name
          optional_rules&.find { |r| r.to_s.include?('map_') }&.to_s&.delete_prefix('map_')&.downcase
        end

        def map_name
          @map_name ||= find_map_name || 'base'
        end

        def layout
          send("map_#{map_name}_layout")
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
          @game_capitalizaton ||= send("map_#{map_name}_game_capitalization")
        end

        def init_corporations(stock_market)
          game_corporations.map do |corporation|
            self.class::CORPORATION_CLASS.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: game_capitalization,
              **corporation.merge(corporation_opts),
            )
          end
        end

        def find_corp(corps, sym)
          corps.find { |c| c[:sym] == sym }
        end

        def corporation_opts
          two_player? ? { max_ownership_percent: 70 } : {}
        end

        def location_name(coord)
          @location_names ||= game_location_names

          @location_names[coord]
        end

        def game_market
          send("map_#{map_name}_game_market")
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
          proto = send("map_#{map_name}_game_phases")
          proto.each { |pp| phases << pp.dup }

          if respond_to?("map_#{map_name}_post_game_phases")
            phases = send("map_#{map_name}_post_game_phases", phases)
          else
            # change last phase based on train roster
            phases.last[:name] = game_trains.last[:name]
            phases.last[:on] = game_trains.last[:name]
          end

          phases
        end

        def half_dividend_by_map?
          return game_capitalization == :incremental unless respond_to?("map_#{map_name}_half_dividend")

          send("map_#{map_name}_half_dividend")
        end

        def share_price_change_for_dividend_as_full_cap_by_map?
          return game_capitalization == :full unless respond_to?("map_#{map_name}_share_price_change_for_dividend_as_full_cap")

          send("map_#{map_name}_share_price_change_for_dividend_as_full_cap")
        end

        def movement_type_at_emr_share_issue_by_map
          return :left_block unless respond_to?("map_#{map_name}_movement_type_at_emr_share_issue")

          send("map_#{map_name}_movement_type_at_emr_share_issue")
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

          ###################################################
          # Default constant overrides for most maps
          # (to be re-overridden if needed by specific maps)
          #
          redef_const(:CURRENCY_FORMAT_STR, '$%s')
          redef_const(:COLOR_SEQUENCE, %i[white yellow green brown gray])
          redef_const(:GAME_END_CHECK, { bankrupt: :immediate, final_phase: :one_more_full_or_set })
          redef_const(:TILE_LAYS, [{ lay: true, upgrade: true, cost: 0 }])

          if game_capitalization == :incremental
            ######################################################
            # Default constant overrides for Incremental Cap maps
            #
            redef_const(:SELL_BUY_ORDER, :sell_buy)
            redef_const(:SELL_AFTER, :after_sr_floated)
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
          send("map_#{map_name}_constants")

          #################################################
          # Map-specific setup
          #
          return unless respond_to?("map_#{map_name}_setup")

          send("map_#{map_name}_setup")
        end

        def init_round
          return send("map_#{map_name}_init_round") if respond_to?("map_#{map_name}_init_round")

          return super unless game_companies.empty?

          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter = 1
          stock_round
        end

        def operating_steps
          if respond_to?("map_#{map_name}_operating_steps")
            send("map_#{map_name}_operating_steps")
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

        # hijack method to see if game should end
        def reorder_players
          if corporations.none?(&:floated)
            @log << '-- Stock round ended with no floated corporations. Ending game.'
            end_game!
          end

          super
        end

        def next_round!
          return super unless respond_to?("map_#{map_name}_next_round!")

          send("map_#{map_name}_next_round!")
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
          return false unless respond_to?("map_#{map_name}_upgrade_ignore_num_cities")

          send("map_#{map_name}_upgrade_ignore_num_cities", from)
        end

        def or_round_finished
          return unless respond_to?("map_#{map_name}_or_round_finished")

          send("map_#{map_name}_or_round_finished")
        end

        def rust_trains!(train, entity)
          return super unless respond_to?("map#{map_name}_rust_trains!")

          send("map_#{map_name}_rust_trains!", train, entity)
        end

        def close_corporation(corporation, quiet: false)
          super

          corporation = reset_corporation(corporation)
          hex_by_id(corporation.coordinates).tile.add_reservation!(corporation, corporation.city)
          @corporations << corporation

          @log << "#{corporation.name} is now available to start"
          return unless respond_to?("map_#{map_name}_close_corporation_extra")

          send("map_#{map_name}_close_corporation_extra", corporation)
        end

        def check_other(route)
          return unless respond_to?("map_#{map_name}_check_other")

          send("map_#{map_name}_check_other", route)
        end

        def post_lay_tile(entity, tile)
          return unless respond_to?("map_#{map_name}_post_lay_tile")

          send("map_#{map_name}_post_lay_tile", entity, tile)
        end

        def token_same_hex?(entity, hex, token)
          return false unless respond_to?("map_#{map_name}_token_same_hex?")

          send("map_#{map_name}_token_same_hex?", entity, hex, token)
        end

        def company_header(company)
          return super unless respond_to?("map_#{map_name}_company_header")

          send("map_#{map_name}_company_header", company)
        end

        def can_par?(corporation, entity)
          return super unless respond_to?("map_#{map_name}_can_par?")

          send("map_#{map_name}_can_par?", corporation, entity)
        end

        def after_par(corporation)
          return super unless respond_to?("map_#{map_name}_after_par")

          send("map_#{map_name}_after_par", corporation)
        end

        def tokener_check_connected(entity, city, hex)
          return true unless respond_to?("map_#{map_name}_tokener_check_connected")

          send("map_#{map_name}_tokener_check_connected", entity, city, hex)
        end

        def tokener_available_hex(entity, hex)
          return true unless respond_to?("map_#{map_name}_tokener_available_hex")

          send("map_#{map_name}_tokener_available_hex", entity, hex)
        end

        def revenue_for(route, stops)
          revenue = super

          return revenue unless respond_to?("map_#{map_name}_extra_revenue_for")

          revenue + send("map_#{map_name}_extra_revenue_for", route, stops)
        end

        def revenue_str(route)
          revenue_str = super

          return revenue_str unless respond_to?("map_#{map_name}_extra_revenue_str")

          revenue_str + send("map_#{map_name}_extra_revenue_str", route)
        end

        def extra_revenue(entity, routes)
          return super unless respond_to?("map_#{map_name}_extra_revenue")

          send("map_#{map_name}_extra_revenue", entity, routes)
        end

        def submit_revenue_str(routes, show_subsidy)
          return super unless respond_to?("map_#{map_name}_submit_revenue_str")

          send("map_#{map_name}_submit_revenue_str", routes, show_subsidy)
        end

        def timeline
          return super unless respond_to?("map_#{map_name}_timeline")

          send("map_#{map_name}_timeline")
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
          return false unless respond_to?("map_#{map_name}_can_remove_icon?")

          send("map_#{map_name}_can_remove_icon?", entity)
        end

        def icon_hexes(entity)
          return [] unless respond_to?("map_#{map_name}_icon_hexes")

          send("map_#{map_name}_icon_hexes", entity)
        end

        def remove_icon(entity, hex_id)
          return unless respond_to?("map_#{map_name}_remove_icon")

          send("map_#{map_name}_remove_icon", entity, hex_id)
        end

        def removable_icon_action_str
          return unless respond_to?("map_#{map_name}_removable_icon_action_str")

          send("map_#{map_name}_removable_icon_action_str")
        end

        def status_str(corporation)
          return super unless respond_to?("map_#{map_name}_status_str")

          send("map_#{map_name}_status_str", corporation)
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
          return super unless respond_to?("map_#{map_name}_place_home_token")

          send("map_#{map_name}_place_home_token", corporation)
        end
      end
    end
  end
end
